Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55038C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:24:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D53C2073D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:24:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D53C2073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30468E00B9; Wed,  6 Feb 2019 07:24:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B073E8E00AA; Wed,  6 Feb 2019 07:24:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F4FB8E00B9; Wed,  6 Feb 2019 07:24:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2698E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:24:56 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id z22so5831594oto.11
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:24:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=Ojj961/53Bcfzm76vFJhYKHHstUcsi9q5IQAvgnDjkw=;
        b=Wy2kOVOvZKzjHOU6ZDGlPQ0JU3aJ5b16SChCKyJAHS40HBaMyUYPWp9/Lzs421izXW
         /6n1NUbelbluoqIXwgarKH7opNmxtcj+QhjHTjhxa/NH08Wk1+gbRLwhQ7qX4mBtOfin
         f3bVELj3NFL8n82e6o74PpNvJiN5IqV2P1eIpd468amAH2JyoPby0rA9oZEBXbROeNJ9
         RaU8zS/bw+ErzEkfABzX+/gFW0iX0SKrHA1J2uuTlHHdYJXt2h5ALWVncTiXAnvbUgJ4
         FZCeK4dc7tHnLKGkQgDAo3cLQYbAoNqIt5/5tN7dCmV/rLWgK38Gtw1F21jMfG/YQL9B
         n1Mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuaB+XryP4QN551cvHe+UR+rVIeU6DBkxLP0moqPlxeAxUxQ/KEK
	srKgfgA9H67iZakr9aK6WXgmL1OHAZ1tNuJZUNj+rpa+pKDzIj3i/2R+llcY+Nd3I9UulPcOl5A
	MelbTb60cEi0g+2k5hoNS40l3CrqosXKABa4b0chFQ5bhdU8HpzraEUJoIT7lcyBorQ==
X-Received: by 2002:a9d:6b11:: with SMTP id g17mr5426611otp.70.1549455896183;
        Wed, 06 Feb 2019 04:24:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZESwi6CwaIMETgL8XPRAFqe+Ns66bbT+ANtgGe+IFyuzeuH+2JOQOH+OA5a6HJU/pXpgGf
X-Received: by 2002:a9d:6b11:: with SMTP id g17mr5426562otp.70.1549455894862;
        Wed, 06 Feb 2019 04:24:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455894; cv=none;
        d=google.com; s=arc-20160816;
        b=Tec2xCV4stL721ipVpPjsEXkkjYP8pCJHBga8ZOI1bvWygAuVWwkApOYfhsO4ha5C/
         KxspuBXpuNHCyydFMTF3muax7NX046qbzxA9bUnhXxg1qyxQDwOWOYJYzQdRjbQ5alKF
         0OemfY1ph9+vUghb12leJ4r4PfOmn57S2BHNEVdEz15XcMRoz9lKm8K8HCcA1FhJLWbQ
         rzW7ravRZBKDAgjrQ3Ueh32TjUqX5CMqiQwHPac1ghgecTHWFrTG6D/k+xdrgw9yZNzE
         8be84l5a4XP9MzYSm0RlLxyq39/kSDPFZnQlJi3kAc+dmb7J6deSZiW0Ip8euggwjaVR
         Z+hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=Ojj961/53Bcfzm76vFJhYKHHstUcsi9q5IQAvgnDjkw=;
        b=lT9UZU11U3y0rPU7kAZtUDiwcJx12M3jgEto4fHtRAnrHZw0CrdYrhCFU4lP9f3AkU
         kx/ADuVgIpgA8GZYQxzhhwHDnhtthHTBXtgj2HSi1ryPA5n1gp6uueAygKh5DT9vdmIM
         GAUIfkdibEDbjVukr8zz7Dq9z7hvTjpIH9QlF2V1rpskM7b2xSI0zP2v0rNSE7FyVrcL
         STLbEH0MnDHPlKAtRT2F4R7/a3RHQhY4S5frMUJL8d9Cs7Tg/sRmcd7dfxbA1CT3uc2h
         99mgKhBXm+mW7DJZi2lwpQ8k09DZbh1eO6yCLf1dsmHZx1jqbS4Dfur+CR7Gdp2MPlp5
         gwfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id a110si10539679otc.124.2019.02.06.04.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:24:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id C9EFFDC6DAE8CF0E7C38;
	Wed,  6 Feb 2019 20:24:49 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:24:46 +0800
Date: Wed, 6 Feb 2019 12:24:35 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 08/10] node: Add memory caching attributes
Message-ID: <20190206122435.00001f95@huawei.com>
In-Reply-To: <20190124230724.10022-9-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-9-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 16:07:22 -0700
Keith Busch <keith.busch@intel.com> wrote:

> System memory may have side caches to help improve access speed to
> frequently requested address ranges. While the system provided cache is
> transparent to the software accessing these memory ranges, applications
> can optimize their own access based on cache attributes.
> 
> Provide a new API for the kernel to register these memory side caches
> under the memory node that provides it.
> 
> The new sysfs representation is modeled from the existing cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/<cpu>/side_cache/.
<cpu>/cache/?

> Unlike CPU cacheinfo though, the node cache level is reported from
> the view of the memory. A higher number is nearer to the CPU, while
> lower levels are closer to the backing memory. Also unlike CPU cache,
> it is assumed the system will handle flushing any dirty cached memory
> to the last level on a power failure if the range is persistent memory.
That's a design choice.  A sensible one perhaps, but not a requirement of
this infrastructure.  Not that it really matters as who reads patch
descriptions after they are applied? :)

> 
> The attributes we export are the cache size, the line size, associativity,
> and write back policy.
> 
> Add the attributes for the system memory side caches to sysfs stable
> documentation.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
A few minor points inline.

> ---
>  Documentation/ABI/stable/sysfs-devices-node |  34 +++++++
>  drivers/base/node.c                         | 153 ++++++++++++++++++++++++++++
>  include/linux/node.h                        |  34 +++++++
>  3 files changed, 221 insertions(+)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 41cb9345e1e0..26327279b6b6 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -142,3 +142,37 @@ Contact:	Keith Busch <keith.busch@intel.com>
>  Description:
>  		This node's write latency in nanoseconds when access
>  		from nodes found in this class's linked initiators.
> +
> +What:		/sys/devices/system/node/nodeX/side_cache/indexY/associativity
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The caches associativity: 0 for direct mapped, non-zero if
> +		indexed.
> +
> +What:		/sys/devices/system/node/nodeX/side_cache/indexY/level
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		This cache's level in the memory hierarchy. Matches 'Y' in the
> +		directory name.

Mentioned in the docs, but I'm not sure why we need this given it matches the
directory name in which it is found...  For the cpu caches they aren't the
same (data vs instruction) for example.

> +
> +What:		/sys/devices/system/node/nodeX/side_cache/indexY/line_size
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The number of bytes accessed from the next cache level on a
> +		cache miss.
> +
> +What:		/sys/devices/system/node/nodeX/side_cache/indexY/size
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The size of this memory side cache in bytes.
> +
> +What:		/sys/devices/system/node/nodeX/side_cache/indexY/write_policy
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The cache write policy: 0 for write-back, 1 for write-through,
> +		other or unknown.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 2de546a040a5..9b4cb29863ff 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -205,6 +205,157 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>  		}
>  	}
>  }
> +
> +/**
> + * struct node_cache_info - Internal tracking for memory node caches
> + * @dev:	Device represeting the cache level
> + * @node:	List element for tracking in the node
> + * @cache_attrs:Attributes for this cache level
> + */
> +struct node_cache_info {
> +	struct device dev;
> +	struct list_head node;
> +	struct node_cache_attrs cache_attrs;
> +};
> +#define to_cache_info(device) container_of(device, struct node_cache_info, dev)
> +
> +#define CACHE_ATTR(name, fmt) 						\
> +static ssize_t name##_show(struct device *dev,				\
> +			   struct device_attribute *attr,		\
> +			   char *buf)					\
> +{									\
> +	return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);\
> +}									\
> +DEVICE_ATTR_RO(name);
> +
> +CACHE_ATTR(size, "%llu")
> +CACHE_ATTR(level, "%u")
> +CACHE_ATTR(line_size, "%u")
> +CACHE_ATTR(associativity, "%u")
> +CACHE_ATTR(write_policy, "%u")
> +
> +static struct attribute *cache_attrs[] = {
> +	&dev_attr_level.attr,
> +	&dev_attr_associativity.attr,
> +	&dev_attr_size.attr,
> +	&dev_attr_line_size.attr,
> +	&dev_attr_write_policy.attr,
> +	NULL,
> +};
> +ATTRIBUTE_GROUPS(cache);
> +
> +static void node_cache_release(struct device *dev)
> +{
> +	kfree(dev);
> +}
> +
> +static void node_cacheinfo_release(struct device *dev)
> +{
> +	struct node_cache_info *info = to_cache_info(dev);
> +	kfree(info);
> +}
> +
> +static void node_init_cache_dev(struct node *node)
> +{
> +	struct device *dev;
> +
> +	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
> +	if (!dev)
> +		return;
> +
> +	dev->parent = &node->dev;
> +	dev->release = node_cache_release;
> +	if (dev_set_name(dev, "side_cache"))
> +		goto free_dev;
> +
> +	if (device_register(dev))
> +		goto free_name;
> +
> +	pm_runtime_no_callbacks(dev);
> +	node->cache_dev = dev;
> +	return;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free_dev:
> +	kfree(dev);
> +}
> +
> +/**
> + * node_add_cache - add cache attribute to a memory node
This is almost but not quite in kernel-doc.
node_add_cache() - add 

IIRC.

> + * @nid: Node identifier that has new cache attributes
> + * @cache_attrs: Attributes for the cache being added
> + */
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs)
> +{
> +	struct node_cache_info *info;
> +	struct device *dev;
> +	struct node *node;
> +
> +	if (!node_online(nid) || !node_devices[nid])
> +		return;
> +
> +	node = node_devices[nid];
> +	list_for_each_entry(info, &node->cache_attrs, node) {
> +		if (info->cache_attrs.level == cache_attrs->level) {
> +			dev_warn(&node->dev,
> +				"attempt to add duplicate cache level:%d\n",
> +				cache_attrs->level);
> +			return;
> +		}
> +	}
> +
> +	if (!node->cache_dev)
> +		node_init_cache_dev(node);
> +	if (!node->cache_dev)
> +		return;
> +
> +	info = kzalloc(sizeof(*info), GFP_KERNEL);
> +	if (!info)
> +		return;
> +
> +	dev = &info->dev;
> +	dev->parent = node->cache_dev;
> +	dev->release = node_cacheinfo_release;
> +	dev->groups = cache_groups;
> +	if (dev_set_name(dev, "index%d", cache_attrs->level))
> +		goto free_cache;
> +
> +	info->cache_attrs = *cache_attrs;
> +	if (device_register(dev)) {
> +		dev_warn(&node->dev, "failed to add cache level:%d\n",
> +			 cache_attrs->level);
> +		goto free_name;
> +	}
> +	pm_runtime_no_callbacks(dev);
> +	list_add_tail(&info->node, &node->cache_attrs);
> +	return;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free_cache:
> +	kfree(info);
> +}
> +
> +static void node_remove_caches(struct node *node)
> +{
> +	struct node_cache_info *info, *next;
> +
> +	if (!node->cache_dev)
> +		return;
> +
> +	list_for_each_entry_safe(info, next, &node->cache_attrs, node) {
> +		list_del(&info->node);
> +		device_unregister(&info->dev);
> +	}
> +	device_unregister(node->cache_dev);
> +}
> +
> +static void node_init_caches(unsigned int nid)
> +{
> +	INIT_LIST_HEAD(&node_devices[nid]->cache_attrs);
> +}
> +#else
> +static void node_init_caches(unsigned int nid) { }
> +static void node_remove_caches(struct node *node) { }
>  #endif
>  
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
> @@ -489,6 +640,7 @@ void unregister_node(struct node *node)
>  {
>  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
>  	node_remove_accesses(node);
> +	node_remove_caches(node);
>  	device_unregister(&node->dev);
>  }
>  
> @@ -781,6 +933,7 @@ int __register_one_node(int nid)
>  	INIT_LIST_HEAD(&node_devices[nid]->access_list);
>  	/* initialize work queue for memory hot plug */
>  	init_node_hugetlb_work(nid);
> +	node_init_caches(nid);
>  
>  	return error;
>  }
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 2db077363d9c..842e4ab2ae6d 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -37,6 +37,36 @@ struct node_hmem_attrs {
>  };
>  void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>  			 unsigned access);
> +
> +enum cache_associativity {
> +	NODE_CACHE_DIRECT_MAP,
> +	NODE_CACHE_INDEXED,
> +	NODE_CACHE_OTHER,
> +};
> +
> +enum cache_write_policy {
> +	NODE_CACHE_WRITE_BACK,
> +	NODE_CACHE_WRITE_THROUGH,
> +	NODE_CACHE_WRITE_OTHER,
> +};
> +
> +/**
> + * struct node_cache_attrs - system memory caching attributes
> + *
> + * @associativity:	The ways memory blocks may be placed in cache
> + * @write_policy:	Write back or write through policy
> + * @size:		Total size of cache in bytes
> + * @line_size:		Number of bytes fetched on a cache miss
> + * @level:		Represents the cache hierarchy level
> + */
> +struct node_cache_attrs {
> +	enum cache_associativity associativity;
> +	enum cache_write_policy write_policy;
> +	u64 size;
> +	u16 line_size;
> +	u8  level;
> +};
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
>  #endif
>  
>  struct node {
> @@ -45,6 +75,10 @@ struct node {
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>  	struct work_struct	node_work;
>  #endif
> +#ifdef CONFIG_HMEM_REPORTING
> +	struct list_head cache_attrs;
> +	struct device *cache_dev;
> +#endif
>  };
>  
>  struct memory_block;


