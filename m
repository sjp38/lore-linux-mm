Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A350FC282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7CA2175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:26:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7CA2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62B38E00BC; Wed,  6 Feb 2019 07:26:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E383C8E00AA; Wed,  6 Feb 2019 07:26:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4FDD8E00BC; Wed,  6 Feb 2019 07:26:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A49278E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:26:52 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id d93so5836777otb.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:26:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=5DWGmZ7AUVselKZP5jzTuPiXxXwGlq9P4Lik+hpgk5s=;
        b=TR3q4HInyo82bGwfpnms0laroorYSPumXvKAlv9bENG0+IADO/ILpK6sZPLzVh9QNf
         bpBAftrn3QjW7Jl2tpmy4pEPcJmauul/yQ4yUniugAcrtdbNNY2N5eYTo3mvCMaYYI0U
         r1VdeBMTZfF2VA1kA21SaUrpTW0XIFtP6H3DHlf9vAke/nSmd20AoNpg3eMzt5FsL1H3
         g+T23rXrBzrJKJQf7ER1IMigvpki/bnMhPyeU4UAOz4zCF63YzC6s+iVHV8YkdxA/UfI
         nWtPJbDLL7QHJ7r9aj2NXKHlhoced/r9hIovz3UQjuMyXEKV8Focflu/Y1FUdVAc5wa1
         UWKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuac3jY/T/Ll8EJw3JbudbjTnLI1rEbYjXJNFY8tk+U3xlfvahYF
	bMmL31kev4hEK8MCBX2Rb3NWM9Mnr13Fza5hYrykaRRuGA6RlgIQyf40d3niljjnuqBXmpTXdTG
	tiVKONX8uQo04qiNqQlQE+wa1iY0EdB2r2E355xGv6iRGeArdrgQ1/HFcvt9PYTlnoA==
X-Received: by 2002:aca:31cb:: with SMTP id x194mr5099241oix.213.1549456012380;
        Wed, 06 Feb 2019 04:26:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAp2U7BlPFaVML6oc+vooFZo9hqFJKxEV95F7qXUCYjZTZ1+Uvsge/YA6y7t1A9izlKiGO
X-Received: by 2002:aca:31cb:: with SMTP id x194mr5099215oix.213.1549456011477;
        Wed, 06 Feb 2019 04:26:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549456011; cv=none;
        d=google.com; s=arc-20160816;
        b=R1vTfS0Kady44LJBQJzx6UkG7dLu5+j0Bx7F0v4CxgvhKw53WXmDfERnUj0elTLur5
         UIwJ3Xho9W6nyeHXdTmaUCix0RsfpNJG86mnbVV6OBOOuEPoV4ixxMZk7EvAp+h0ynLv
         cx2RyiRJOF841WrEPhCZGpEzno/RapNJpZTcibzN6eO8fDWwvXW1jQ6kcK1RAb9b0cuP
         mZmmvwtEaRrrLHH+gcYQUguE9tCgx49cwhNM3ytxub7awN19XtAjiqNKkaKWRPox8+MW
         8ER/Rcro11kMg64om6u0wqWJxSmjxnNpYhSA1u2wHks6lwXe6aqDLUWnZCbYV/9yr2zk
         0nzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=5DWGmZ7AUVselKZP5jzTuPiXxXwGlq9P4Lik+hpgk5s=;
        b=INKdJ2L4hqSs1Rsuci/oJuK+ch+np7kKzvFVRS2sg6M7K3SdsVHqOnOlRr8k9LB//P
         kQwehQtOqPf6rja2i0iHEk+/EY2a/N8+F/m3aoAUgKkMv+xBevFovoNC2onJ8ZolsY5M
         S0ya50ckhxYDbWqJOCqULShql6DMSe31d8/JkKToZPfBEVSs8hVPOew4qU3/nIg2OkpC
         vM3DXlImKclBrgnVi4/BKLNCSPNwxwD1tJhl/pyPZZw8IHot54+bhQAzuzi8gHCYeopv
         7WOy8CQeXKKS21p1CtcOau5t1jGrB0VLrM7k8R8N57RyHx3xbEJXGl0fCRUwEPaKu9bu
         b2JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l135si9435081oih.146.2019.02.06.04.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:26:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 50FD01F3BD5ADB504451;
	Wed,  6 Feb 2019 20:26:46 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:26:44 +0800
Date: Wed, 6 Feb 2019 12:26:35 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190206122635.00005d37@huawei.com>
In-Reply-To: <20190124230724.10022-5-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-5-keith.busch@intel.com>
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

On Thu, 24 Jan 2019 16:07:18 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Systems may be constructed with various specialized nodes. Some nodes
> may provide memory, some provide compute devices that access and use
> that memory, and others may provide both. Nodes that provide memory are
> referred to as memory targets, and nodes that can initiate memory access
> are referred to as memory initiators.
> 
> Memory targets will often have varying access characteristics from
> different initiators, and platforms may have ways to express those
> relationships. In preparation for these systems, provide interfaces for
> the kernel to export the memory relationship among different nodes memory
> targets and their initiators with symlinks to each other.
> 
> If a system provides access locality for each initiator-target pair, nodes
> may be grouped into ranked access classes relative to other nodes. The
> new interface allows a subsystem to register relationships of varying
> classes if available and desired to be exported.
> 
> A memory initiator may have multiple memory targets in the same access
> class. The target memory's initiators in a given class indicate the
> nodes access characteristics share the same performance relative to other
> linked initiator nodes. Each target within an initiator's access class,
> though, do not necessarily perform the same as each other.
> 
> A memory target node may have multiple memory initiators. All linked
> initiators in a target's class have the same access characteristics to
> that target.
> 
> The following example show the nodes' new sysfs hierarchy for a memory
> target node 'Y' with access class 0 from initiator node 'X':
> 
>   # symlinks -v /sys/devices/system/node/nodeX/access0/
>   relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
> 
>   # symlinks -v /sys/devices/system/node/nodeY/access0/
>   relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
> 
> The new attributes are added to the sysfs stable documentation.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>

A few comments inline.

> ---
>  Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
>  drivers/base/node.c                         | 142 +++++++++++++++++++++++++++-
>  include/linux/node.h                        |   7 +-
>  3 files changed, 171 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..fb843222a281 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:		December 2009
>  Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>  		The node's huge page size control/query attributes.
> -		See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +		See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:		/sys/devices/system/node/nodeX/accessY/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node's relationship to other nodes for access class "Y".
> +
> +What:		/sys/devices/system/node/nodeX/accessY/initiators/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The directory containing symlinks to memory initiator
> +		nodes that have class "Y" access to this target node's
> +		memory. CPUs and other memory initiators in nodes not in
> +		the list accessing this node's memory may have different
> +		performance.

Also seems to contain the characteristics of those accesses.

> +
> +What:		/sys/devices/system/node/nodeX/classY/targets/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The directory containing symlinks to memory targets that
> +		this initiator node has class "Y" access.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..6f4097680580 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -17,6 +17,7 @@
>  #include <linux/nodemask.h>
>  #include <linux/cpu.h>
>  #include <linux/device.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/swap.h>
>  #include <linux/slab.h>
>  
> @@ -59,6 +60,94 @@ static inline ssize_t node_read_cpulist(struct device *dev,
>  static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
>  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
>  
> +/**
> + * struct node_access_nodes - Access class device to hold user visible
> + * 			      relationships to other nodes.
> + * @dev:	Device for this memory access class
> + * @list_node:	List element in the node's access list
> + * @access:	The access class rank
> + */
> +struct node_access_nodes {
> +	struct device		dev;
> +	struct list_head	list_node;
> +	unsigned		access;
> +};
> +#define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
> +
> +static struct attribute *node_init_access_node_attrs[] = {
> +	NULL,
> +};
> +
> +static struct attribute *node_targ_access_node_attrs[] = {
> +	NULL,
> +};
> +
> +static const struct attribute_group initiators = {
> +	.name	= "initiators",
> +	.attrs	= node_init_access_node_attrs,
> +};
> +
> +static const struct attribute_group targets = {
> +	.name	= "targets",
> +	.attrs	= node_targ_access_node_attrs,
> +};
> +
> +static const struct attribute_group *node_access_node_groups[] = {
> +	&initiators,
> +	&targets,
> +	NULL,
> +};
> +
> +static void node_remove_accesses(struct node *node)
> +{
> +	struct node_access_nodes *c, *cnext;
> +
> +	list_for_each_entry_safe(c, cnext, &node->access_list, list_node) {
> +		list_del(&c->list_node);
> +		device_unregister(&c->dev);
> +	}
> +}
> +
> +static void node_access_release(struct device *dev)
> +{
> +	kfree(to_access_nodes(dev));
> +}
> +
> +static struct node_access_nodes *node_init_node_access(struct node *node,
> +						       unsigned access)
> +{
> +	struct node_access_nodes *access_node;
> +	struct device *dev;
> +
> +	list_for_each_entry(access_node, &node->access_list, list_node)
> +		if (access_node->access == access)
> +			return access_node;
> +
> +	access_node = kzalloc(sizeof(*access_node), GFP_KERNEL);
> +	if (!access_node)
> +		return NULL;
> +
> +	access_node->access = access;
> +	dev = &access_node->dev;
> +	dev->parent = &node->dev;
> +	dev->release = node_access_release;
> +	dev->groups = node_access_node_groups;
> +	if (dev_set_name(dev, "access%u", access))
> +		goto free;
> +
> +	if (device_register(dev))
> +		goto free_name;
> +
> +	pm_runtime_no_callbacks(dev);
> +	list_add_tail(&access_node->list_node, &node->access_list);
> +	return access_node;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free:
> +	kfree(access_node);
> +	return NULL;
> +}
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>  			struct device_attribute *attr, char *buf)
> @@ -340,7 +429,7 @@ static int register_node(struct node *node, int num)
>  void unregister_node(struct node *node)
>  {
>  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
> -
> +	node_remove_accesses(node);
>  	device_unregister(&node->dev);
>  }
>  
> @@ -372,6 +461,56 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
>  				 kobject_name(&node_devices[nid]->dev.kobj));
>  }
>  
> +/**
> + * register_memory_node_under_compute_node - link memory node to its compute
> + *					     node for a given access class.
> + * @mem_node:	Memory node number
> + * @cpu_node:	Cpu  node number
> + * @access:	Access class to register
> + *
> + * Description:
> + * 	For use with platforms that may have separate memory and compute nodes.
I would drop that first line as it also applies on systems where this isn't
true and will be there if we want hmat simply for the better stats.

> + * 	This function will export node relationships linking which memory
> + * 	initiator nodes can access memory targets at a given ranked access
> + * 	class.
> + */
> +int register_memory_node_under_compute_node(unsigned int mem_nid,
> +					    unsigned int cpu_nid,
> +					    unsigned access)
> +{
> +	struct node *init_node, *targ_node;
> +	struct node_access_nodes *initiator, *target;
> +	int ret;
> +
> +	if (!node_online(cpu_nid) || !node_online(mem_nid))
> +		return -ENODEV;

What do we do under memory/node hotplug?  More than likely that will
apply in such systems (it does in mine for starters).
Clearly to do the full story we would need _HMT support etc but
we can do the prebaked version by having hmat entries for nodes
that aren't online yet (like we do for SRAT).

Perhaps one for a follow up patch set.  However, I'd like an
pr_info to indicate that the node is listed but not online currently.

> +
> +	init_node = node_devices[cpu_nid];
> +	targ_node = node_devices[mem_nid];
> +	initiator = node_init_node_access(init_node, access);
> +	target = node_init_node_access(targ_node, access);
> +	if (!initiator || !target)
> +		return -ENOMEM;
If one of these fails and the other doesn't + the one that succeeded
did an init, don't we end up leaking a device here?  I'd expect this
function to not leave things hanging if it has an error. It should
unwind anything it has done.  It has been added to the list so
could be cleaned up later, but I'm not seeing that code. 

These only get cleaned up when the node is removed.

> +
> +	ret = sysfs_add_link_to_group(&initiator->dev.kobj, "targets",
> +				      &targ_node->dev.kobj,
> +				      dev_name(&targ_node->dev));
> +	if (ret)
> +		return ret;
> +
> +	ret = sysfs_add_link_to_group(&target->dev.kobj, "initiators",
> +				      &init_node->dev.kobj,
> +				      dev_name(&init_node->dev));
> +	if (ret)
> +		goto err;
> +
> +	return 0;
> + err:
> +	sysfs_remove_link_from_group(&initiator->dev.kobj, "targets",
> +				     dev_name(&targ_node->dev));
> +	return ret;
> +}
> +
>  int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
>  {
>  	struct device *obj;
> @@ -580,6 +719,7 @@ int __register_one_node(int nid)
>  			register_cpu_under_node(cpu, nid);
>  	}
>  
> +	INIT_LIST_HEAD(&node_devices[nid]->access_list);
>  	/* initialize work queue for memory hot plug */
>  	init_node_hugetlb_work(nid);
>  
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 257bb3d6d014..f34688a203c1 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -17,11 +17,12 @@
>  
>  #include <linux/device.h>
>  #include <linux/cpumask.h>
> +#include <linux/list.h>
>  #include <linux/workqueue.h>
>  
>  struct node {
>  	struct device	dev;
> -
> +	struct list_head access_list;
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>  	struct work_struct	node_work;
>  #endif
> @@ -75,6 +76,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  					   unsigned long phys_index);
>  
> +extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> +						   unsigned int cpu_nid,
> +						   unsigned access);
> +
>  #ifdef CONFIG_HUGETLBFS
>  extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
>  					 node_registration_func_t unregister);


