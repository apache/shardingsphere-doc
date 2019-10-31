+++
title = "官档贡献指南"
weight = 5
chapter = true

+++

如果您想帮助贡献ShardingSphere文档或网站，我们很乐意为您提供帮助！任何人都可以贡献，无论您是刚接触项目还是已经使用ShardingSphere很长时间，无论是自我认同的开发人员、最终用户，还是那些无法忍受错别字的人，都可以对文档或者网站进行贡献。

在贡献者指南里，已经提到如何提交Issues与PR,  这里我们将要介绍如何给官档提交PR。

## 前置条件

- 熟悉[官档](https://shardingsphere.apache.org)
- 熟悉[GitHub 协同开发流程](https://help.github.com/categories/collaborating-with-issues-and-pull-requests/)
- 熟练掌握markdown
- 熟悉[Hugo](https://gohugo.io/)

## 使用`master`分支

如果您是一个新手，您能像下面这样准备依赖：

1. 下载 [shardingsphere-doc](https://github.com/apache/incubator-shardingsphere-doc.git):

```
## download the code of shardingsphere-doc
git clone https://github.com/apache/incubator-shardingsphere-doc.git
```

## incubator-shardingsphere-doc 模块设计

#### 项目构造

```
incubator-shardingsphere-doc
├─community
│  ├─archetypes
│  ├─content
│  │  ├─company
│  │  ├─contribute
│  │  ├─team
│  │  └─security
│  ├─layouts
│  ├─static
│  └─themes
├─dist
├─document
│  ├─current
│  │  ├─archetypes
│  │  ├─content
│  │  │  ├─downloads
│  │  │  ├─faq
│  │  │  ├─features
│  │  │  │  ├─orchestration
│  │  │  │  ├─read-write-split
│  │  │  │  ├─sharding
│  │  │  │  │  ├─concept
│  │  │  │  │  ├─other-features
│  │  │  │  │  ├─principle
│  │  │  │  │  └─use-norms
│  │  │  │  ├─spi
│  │  │  │  └─transaction
│  │  │  │      ├─concept
│  │  │  │      ├─function
│  │  │  │      └─principle
│  │  │  ├─manual
│  │  │  │  ├─sharding-jdbc
│  │  │  │  │  ├─configuration
│  │  │  │  │  └─usage
│  │  │  │  ├─sharding-proxy
│  │  │  │  ├─sharding-sidecar
│  │  │  │  └─sharding-ui
│  │  │  ├─overview
│  │  │  └─quick-start
│  │  ├─i18n
│  │  ├─layouts
│  │  ├─static
│  │  └─themes
│  └─legacy   
│      ├─1.x
│      │  └─cn
│      ├─2.x
│      │  ├─cn
│      │  └─en
│      └─3.x
│          ├─community
│          ├─document
│          ├─images
│          └─schema
└─homepage
    ├─css
    ├─images
    └─schema
```

## 文档基础知识

ShardingSphere文档使用Markdown编写，并使用Hugo进行处理生成html，部署于[asf-site](https://github.com/apache/incubator-shardingsphere-doc/tree/asf-site)分支，源代码位于[Github](https://github.com/apache/incubator-shardingsphere-doc/tree/master) 。

- [官方主页](https://shardingsphere.apache.org/index_zh.html)文档源存储在`/homepage/`
- [官方文档](https://shardingsphere.apache.org/document/current/cn/overview/)源存储在`/document/`，其中官方教程的[最新版本](https://shardingsphere.apache.org/document/current/cn/overview/)文档源存储在`/document/current/`，历史版本文档源存储在`/document/legacy/`
- [社区介绍及贡献](https://shardingsphere.apache.org/community/cn/contribute/)相关文档源都储存在`/community/content/`

您可以从[Github](https://github.com/apache/incubator-shardingsphere-doc/issues)网站上提交问题，编辑内容和查看其他人的更改

## 页面模板

页面模板位于themes中的 `layouts/partials/` 目录中

## 提出具体可查找的问题

任何拥有Github帐户的人都可以针对ShardingSphere文档提出问题（错误报告）。如果您发现错误，即使您不知道如何修复它，也应提出问题。

### 如何提出问题

1. 附加出现问题的文档链接

2. 详细描述问题

3. 描述问题对用户造成的困扰

4. 提出建议修复的方式

5. 在[Issues](https://github.com/apache/incubator-shardingsphere-doc/issues)中`New issue` 提出您的问题

## 提交更改

### 操作步骤

1. 在master分支目录结构中定位出您要操作的文件
2. 文件操作完成后，提PR到master分支

## 约定

- 非特别说明，请使用 **Hugo 0.37.1**版本

- asf-site分支由官方定期更新，您无需向asf-site提交PR



