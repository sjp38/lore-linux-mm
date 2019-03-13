Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBAB4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:18:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 647FA21019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:18:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 647FA21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9EBE8E0011; Wed, 13 Mar 2019 19:18:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4EA28E0001; Wed, 13 Mar 2019 19:18:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3E158E0011; Wed, 13 Mar 2019 19:18:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3ED8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:18:22 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q26so1542048otf.19
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:18:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=f6SvYlx/F883vR+Z7/H0ZrIgNORsq0y2rNgyJLV3sLU=;
        b=Isgq0CqWbFUHrRWvxUeGrvbypfiOtKxpMNaoHtlJ+AIWbbbp6Z/aObMXrGZ0Kx1pVR
         4fE5TLLs3fANqGI3JD8TSe0t/LV+g+8Ujz7lwRr6whm4zaO8PfMNmtBBqjNAJrLV83rs
         SmFUaMR3598oFPo6S3+1PB1xbdPWjhdTEWQu3qiM7nQSej1hSR7mWWfGrnzpICFgp79h
         HOik9XEe4pg12ADmfwx/RZSsoJgGQoP2wNbMIn7BEuuaAXRuoy24Zfc5RgvOCPMNN17w
         EcjBJu1nKRTe6INeJt8Jf6b8tBLMmi1CR7alWrIpfI7lIlwccnFZJqjyfKS8qIrVd4XV
         wgdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVnzO2fNGwV0VQMRT/C6wmUQ4QD7o550wfzRm6LqzsPyscVPRpR
	e2+6qHC4BPBLinbcJYX4IFHmSWZHEuIFwZeOnNXPCxPwgc+aO1W1oVgWCVv76pElaBtaxSqZOU2
	FqZrVqF3PiYlwp9Ht5CAx1NgYAVQsrlzBQPXm6qGHyfdX4K9wGmSnbJ+dcfBhJpGe0hzno1Xyjm
	0cC1yvFaoj7YBerbhaVaICmMJ2BIHmCQTtnfn0x33H1zcgmmP1Lj71pV2EPXyMLMpoHWILvIE4r
	qi1F2/m5jMZF7chwQaUyiTn6fBmeHWpWrKGc3LTnBqNNHcN1atGqxX5oHBc1R7RinZTpOrmMvBz
	VQA7w479WmPILDiWtx0dcwZKuS0FRPWemZA94c3tjUne41xr8bjY0F48bDgPP2HUZ3lY0rwgWA=
	=
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr12135191otc.224.1552519102191;
        Wed, 13 Mar 2019 16:18:22 -0700 (PDT)
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr12135163otc.224.1552519101270;
        Wed, 13 Mar 2019 16:18:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552519101; cv=none;
        d=google.com; s=arc-20160816;
        b=uomGAgzoCZ9A08Rx/ENC1KQFqYWFRiqbma1edMw+7jzoTdRMDrKNccf0LITxKypJ2x
         JwcnlRWaU3fYX0yNqP8C5YxKmRNrgRx8GBhxkrm95rcBtN1ZiiV31YmZAajG/HWiOqKn
         YC1s/f376eXBN/RkPnAPoosbIK9n0HmFtPZsdoeIxpCOn3sL1svu+HzwqddTvJXZzkCv
         n5urkNIf0mDXlDLqVGBo8noZDq3QgI4XU1LIiB9O/hh5G9gw0ZE08OQ98LRTJfsVHmvN
         eAT00U81y4LvJKfP7QObkV4FP3jDO0UKU53JLIV0aH4zC4y+cWndRtqpTuHfHPm0ONX7
         nmfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=f6SvYlx/F883vR+Z7/H0ZrIgNORsq0y2rNgyJLV3sLU=;
        b=IOtaMLGZqT134/KPCYNINDa9VIVMQ2ko71sKxC8ZLhh4KvAZKCw3BHoktqe4sXcw6S
         10NJyhvfeuZY0Ne0pqiO7mQAZzuaPPj8tuajZ/dV59oGPxAct6PbYztNpkTRJBE8HxnX
         bnTdpMqLENSChCcJKBB3qokNdCYu7bVjVa22FdZUljj1m1zuEa5WVmN7Guazv6O5J0R8
         j5v6eY9ArDIH+M6OOizYA5NcfLq9lligSRe0r3qze++DRxADOT9RaY1ct+uoRI1pgOtA
         3st3vDvukvUQLlGJeHWUogGOO8KYiOePnpfhro4jd0B8S0y/40EJXySq975v8SkKoXhk
         IccA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a186sor6856419oif.108.2019.03.13.16.18.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 16:18:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzCExDtKDvNArYMQv0H+xCit2nQ8ryBNUAdxmAXIjCr+K0NST0v6WEB+YFkrY84UVuilo3iRuHLwl9wnaowSB8=
X-Received: by 2002:aca:88b:: with SMTP id 133mr375365oii.95.1552519100857;
 Wed, 13 Mar 2019 16:18:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190311205606.11228-1-keith.busch@intel.com> <20190311205606.11228-7-keith.busch@intel.com>
In-Reply-To: <20190311205606.11228-7-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 14 Mar 2019 00:18:09 +0100
Message-ID: <CAJZ5v0jsFoAxOvUjBx0w+-3v8Y5QhRgxGJEqcGQ38XoPmP=a_A@mail.gmail.com>
Subject: Re: [PATCHv8 06/10] node: Add memory-side caching attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, 
	Jonathan Cameron <jonathan.cameron@huawei.com>, Brice Goglin <Brice.Goglin@inria.fr>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 9:55 PM Keith Busch <keith.busch@intel.com> wrote:
>
> System memory may have caches to help improve access speed to frequently
> requested address ranges. While the system provided cache is transparent
> to the software accessing these memory ranges, applications can optimize
> their own access based on cache attributes.
>
> Provide a new API for the kernel to register these memory-side caches
> under the memory node that provides it.
>
> The new sysfs representation is modeled from the existing cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/<cpu>/cache/.  Unlike CPU
> cacheinfo though, the node cache level is reported from the view of the
> memory. A higher level number is nearer to the CPU, while lower levels
> are closer to the last level memory.
>
> The exported attributes are the cache size, the line size, associativity
> indexing, and write back policy, and add the attributes for the system
> memory caches to sysfs stable documentation.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  Documentation/ABI/stable/sysfs-devices-node |  34 +++++++
>  drivers/base/node.c                         | 151 ++++++++++++++++++++++++++++
>  include/linux/node.h                        |  39 +++++++
>  3 files changed, 224 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 735a40a3f9b2..f7ce68fbd4b9 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -142,3 +142,37 @@ Contact:   Keith Busch <keith.busch@intel.com>
>  Description:
>                 This node's write latency in nanoseconds when access
>                 from nodes found in this class's linked initiators.
> +
> +What:          /sys/devices/system/node/nodeX/memory_side_cache/indexY/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing attributes for the memory-side cache
> +               level 'Y'.
> +
> +What:          /sys/devices/system/node/nodeX/memory_side_cache/indexY/indexing
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The caches associativity indexing: 0 for direct mapped,
> +               non-zero if indexed.
> +
> +What:          /sys/devices/system/node/nodeX/memory_side_cache/indexY/line_size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The number of bytes accessed from the next cache level on a
> +               cache miss.
> +
> +What:          /sys/devices/system/node/nodeX/memory_side_cache/indexY/size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The size of this memory side cache in bytes.
> +
> +What:          /sys/devices/system/node/nodeX/memory_side_cache/indexY/write_policy
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The cache write policy: 0 for write-back, 1 for write-through,
> +               other or unknown.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 2de546a040a5..8598fcbd2a17 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -205,6 +205,155 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>                 }
>         }
>  }
> +
> +/**
> + * struct node_cache_info - Internal tracking for memory node caches
> + * @dev:       Device represeting the cache level
> + * @node:      List element for tracking in the node
> + * @cache_attrs:Attributes for this cache level
> + */
> +struct node_cache_info {
> +       struct device dev;
> +       struct list_head node;
> +       struct node_cache_attrs cache_attrs;
> +};
> +#define to_cache_info(device) container_of(device, struct node_cache_info, dev)
> +
> +#define CACHE_ATTR(name, fmt)                                          \
> +static ssize_t name##_show(struct device *dev,                         \
> +                          struct device_attribute *attr,               \
> +                          char *buf)                                   \
> +{                                                                      \
> +       return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);\
> +}                                                                      \
> +DEVICE_ATTR_RO(name);
> +
> +CACHE_ATTR(size, "%llu")
> +CACHE_ATTR(line_size, "%u")
> +CACHE_ATTR(indexing, "%u")
> +CACHE_ATTR(write_policy, "%u")
> +
> +static struct attribute *cache_attrs[] = {
> +       &dev_attr_indexing.attr,
> +       &dev_attr_size.attr,
> +       &dev_attr_line_size.attr,
> +       &dev_attr_write_policy.attr,
> +       NULL,
> +};
> +ATTRIBUTE_GROUPS(cache);
> +
> +static void node_cache_release(struct device *dev)
> +{
> +       kfree(dev);
> +}
> +
> +static void node_cacheinfo_release(struct device *dev)
> +{
> +       struct node_cache_info *info = to_cache_info(dev);
> +       kfree(info);
> +}
> +
> +static void node_init_cache_dev(struct node *node)
> +{
> +       struct device *dev;
> +
> +       dev = kzalloc(sizeof(*dev), GFP_KERNEL);
> +       if (!dev)
> +               return;
> +
> +       dev->parent = &node->dev;
> +       dev->release = node_cache_release;
> +       if (dev_set_name(dev, "memory_side_cache"))
> +               goto free_dev;
> +
> +       if (device_register(dev))
> +               goto free_name;
> +
> +       pm_runtime_no_callbacks(dev);
> +       node->cache_dev = dev;
> +       return;
> +free_name:
> +       kfree_const(dev->kobj.name);
> +free_dev:
> +       kfree(dev);
> +}
> +
> +/**
> + * node_add_cache() - add cache attribute to a memory node
> + * @nid: Node identifier that has new cache attributes
> + * @cache_attrs: Attributes for the cache being added
> + */
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs)
> +{
> +       struct node_cache_info *info;
> +       struct device *dev;
> +       struct node *node;
> +
> +       if (!node_online(nid) || !node_devices[nid])
> +               return;
> +
> +       node = node_devices[nid];
> +       list_for_each_entry(info, &node->cache_attrs, node) {
> +               if (info->cache_attrs.level == cache_attrs->level) {
> +                       dev_warn(&node->dev,
> +                               "attempt to add duplicate cache level:%d\n",
> +                               cache_attrs->level);
> +                       return;
> +               }
> +       }
> +
> +       if (!node->cache_dev)
> +               node_init_cache_dev(node);
> +       if (!node->cache_dev)
> +               return;
> +
> +       info = kzalloc(sizeof(*info), GFP_KERNEL);
> +       if (!info)
> +               return;
> +
> +       dev = &info->dev;
> +       dev->parent = node->cache_dev;
> +       dev->release = node_cacheinfo_release;
> +       dev->groups = cache_groups;
> +       if (dev_set_name(dev, "index%d", cache_attrs->level))
> +               goto free_cache;
> +
> +       info->cache_attrs = *cache_attrs;
> +       if (device_register(dev)) {
> +               dev_warn(&node->dev, "failed to add cache level:%d\n",
> +                        cache_attrs->level);
> +               goto free_name;
> +       }
> +       pm_runtime_no_callbacks(dev);
> +       list_add_tail(&info->node, &node->cache_attrs);
> +       return;
> +free_name:
> +       kfree_const(dev->kobj.name);
> +free_cache:
> +       kfree(info);
> +}
> +
> +static void node_remove_caches(struct node *node)
> +{
> +       struct node_cache_info *info, *next;
> +
> +       if (!node->cache_dev)
> +               return;
> +
> +       list_for_each_entry_safe(info, next, &node->cache_attrs, node) {
> +               list_del(&info->node);
> +               device_unregister(&info->dev);
> +       }
> +       device_unregister(node->cache_dev);
> +}
> +
> +static void node_init_caches(unsigned int nid)
> +{
> +       INIT_LIST_HEAD(&node_devices[nid]->cache_attrs);
> +}
> +#else
> +static void node_init_caches(unsigned int nid) { }
> +static void node_remove_caches(struct node *node) { }
>  #endif
>
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
> @@ -489,6 +638,7 @@ void unregister_node(struct node *node)
>  {
>         hugetlb_unregister_node(node);          /* no-op, if memoryless node */
>         node_remove_accesses(node);
> +       node_remove_caches(node);
>         device_unregister(&node->dev);
>  }
>
> @@ -781,6 +931,7 @@ int __register_one_node(int nid)
>         INIT_LIST_HEAD(&node_devices[nid]->access_list);
>         /* initialize work queue for memory hot plug */
>         init_node_hugetlb_work(nid);
> +       node_init_caches(nid);
>
>         return error;
>  }
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 4139d728f8b3..1a557c589ecb 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -35,10 +35,45 @@ struct node_hmem_attrs {
>         unsigned int write_latency;
>  };
>
> +enum cache_indexing {
> +       NODE_CACHE_DIRECT_MAP,
> +       NODE_CACHE_INDEXED,
> +       NODE_CACHE_OTHER,
> +};
> +
> +enum cache_write_policy {
> +       NODE_CACHE_WRITE_BACK,
> +       NODE_CACHE_WRITE_THROUGH,
> +       NODE_CACHE_WRITE_OTHER,
> +};
> +
> +/**
> + * struct node_cache_attrs - system memory caching attributes
> + *
> + * @indexing:          The ways memory blocks may be placed in cache
> + * @write_policy:      Write back or write through policy
> + * @size:              Total size of cache in bytes
> + * @line_size:         Number of bytes fetched on a cache miss
> + * @level:             The cache hierarchy level
> + */
> +struct node_cache_attrs {
> +       enum cache_indexing indexing;
> +       enum cache_write_policy write_policy;
> +       u64 size;
> +       u16 line_size;
> +       u8 level;
> +};
> +
>  #ifdef CONFIG_HMEM_REPORTING
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
>  void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>                          unsigned access);
>  #else
> +static inline void node_add_cache(unsigned int nid,
> +                                 struct node_cache_attrs *cache_attrs)
> +{
> +}
> +
>  static inline void node_set_perf_attrs(unsigned int nid,
>                                        struct node_hmem_attrs *hmem_attrs,
>                                        unsigned access)
> @@ -53,6 +88,10 @@ struct node {
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>         struct work_struct      node_work;
>  #endif
> +#ifdef CONFIG_HMEM_REPORTING
> +       struct list_head cache_attrs;
> +       struct device *cache_dev;
> +#endif
>  };
>
>  struct memory_block;
> --
> 2.14.4
>

