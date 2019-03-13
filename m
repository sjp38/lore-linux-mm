Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78B9DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A80220854
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A80220854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A591B8E000C; Wed, 13 Mar 2019 19:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A08558E0001; Wed, 13 Mar 2019 19:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91EBD8E000C; Wed, 13 Mar 2019 19:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 608998E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:13:59 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l198so1549457oib.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=bqpPpA2ePOa7rUNRxAIn2NO6DoPmpAaXyABFnjDDfVE=;
        b=U7hgbZd3rXrKPLJjM9GfZg3DbS9CjkDw0RumdaDQZfYT9PHzud0ljWmo36r3V9ncoX
         Es8Zu4ct/RpJud0e08WrWExaCJnEbz6z5J0wzudE3MQQ/Z5xWWNhMk01F5f0RqUFicii
         bTc0mBVERbnuy4oXP/L4gzpIJLKrAj4JMEGJ5J2XiDVNi75879DrD4Tseha8yiVhSHdn
         kYYSITYQsrDiyGPIUR/TJ7ra45L6NImczKA2AEsX1fE32+H0iJPnQuykTue6D7RNFsrQ
         Lb29cctlJ5iR8UsuMicMNpU2gijqCxsg8usk9NTAG49RABX3ATHh048Qfba9zIH7JBKE
         Hftw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXr1u41wlxJLXAkD0HgkLyG+5jmSYahDrrjiswpXlWqLXbHgwDn
	YtoNBLFylN/FFl7Iy9ehmcY8N5TLxsfQMFxLkeD92XHSG6pB9uxcQGB45Cmt1WWeA/8yfMmTKWb
	hp+etqhTFrWz4hcPHTWdCZkGjyFHScKggfej6xQHcZBG7YEGvh43BiuWppi8YdVs=
X-Received: by 2002:aca:3608:: with SMTP id d8mr350174oia.104.1552518838899;
        Wed, 13 Mar 2019 16:13:58 -0700 (PDT)
X-Received: by 2002:aca:3608:: with SMTP id d8mr350143oia.104.1552518837691;
        Wed, 13 Mar 2019 16:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552518837; cv=none;
        d=google.com; s=arc-20160816;
        b=hx/weT2jffvb9eb1JeSwgpr8iFUp69q4yGej4Ig/7vd/JVuhMMAGoQTQMDHgV2H13i
         /PsAj4dqW+AD1u2KLEamCTtTJlqY1QwPK0fZYahGsCKndouh8AlmDw/MfKuytL6hDS6b
         jNraiuN4m5mPZaa1OvLeNvLJaLHzeAxZ5nGJ3GN+dKvFu8R90zq7tL1aQrc9FOMID5uN
         lWD6AiPP2E2oaVktTcmlwf6uxVRYVPR58L5IX4/NIVrOMnk7PEdT83I+sydfbjrexG41
         ldJvQxxiw6Z+hWRaO1Z7YiLnrbsG1j5AKz56KH6oHHLqMXQ5Q24phpegJx+tk5zbZCMv
         MnKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=bqpPpA2ePOa7rUNRxAIn2NO6DoPmpAaXyABFnjDDfVE=;
        b=aCv6yVeGh5UsE5w1eRcZC35Of5neZx0dteZn6Da+CwCPeBbKTBSXXaIcjjgHB10IdX
         lWOH/+sb2+Ude+0+VEQXG2f/Omduy+rzGV2Y9UZVMpS/FmXdmHmq2neFc6t2svmpYVBT
         RanZDRCYDqAL6zDVU9mU/4R7eKY9foOMDgReI/7DkPAhMlVFvoXtqoOjLGIDaGS3vbPm
         v7kbHeiKPkimrEBgM50odQeod+9ahExFmhkP/VFg5NcjN3Jh/5yZjo5Sg287ssMOrVt9
         vhgovMDO1sLiDF6V3XSg+0dLo7iyUmBltqp1KzzPPx9V9Sejqduv4ialhFAn69JLo+ho
         gclQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p63sor6133710oig.34.2019.03.13.16.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 16:13:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyrqy0X7vvbjSPM/NFYV4jmiwJXyurBWwniPXEyU9u0gh3h7NiHn7ZVKjCqvl4h7YTyIVmxRI5HdPiXV/a1jLs=
X-Received: by 2002:aca:88b:: with SMTP id 133mr367003oii.95.1552518837118;
 Wed, 13 Mar 2019 16:13:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190311205606.11228-1-keith.busch@intel.com> <20190311205606.11228-5-keith.busch@intel.com>
In-Reply-To: <20190311205606.11228-5-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 14 Mar 2019 00:13:45 +0100
Message-ID: <CAJZ5v0gVA3Q3pB0fM7gruxS07194NZADUtmG0iOi-BXZBQLLVA@mail.gmail.com>
Subject: Re: [PATCHv8 04/10] node: Link memory nodes to their compute nodes
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
> Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
>  drivers/base/node.c                         | 142 +++++++++++++++++++++++++++-
>  include/linux/node.h                        |   6 ++
>  3 files changed, 171 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..433bcc04e542 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:                December 2009
>  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>                 The node's huge page size control/query attributes.
> -               See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +               See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:          /sys/devices/system/node/nodeX/accessY/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node's relationship to other nodes for access class "Y".
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory initiator
> +               nodes that have class "Y" access to this target node's
> +               memory. CPUs and other memory initiators in nodes not in
> +               the list accessing this node's memory may have different
> +               performance.
> +
> +What:          /sys/devices/system/node/nodeX/accessY/targets/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory targets that
> +               this initiator node has class "Y" access.
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
> + *                           relationships to other nodes.
> + * @dev:       Device for this memory access class
> + * @list_node: List element in the node's access list
> + * @access:    The access class rank
> + */
> +struct node_access_nodes {
> +       struct device           dev;
> +       struct list_head        list_node;
> +       unsigned                access;
> +};
> +#define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
> +
> +static struct attribute *node_init_access_node_attrs[] = {
> +       NULL,
> +};
> +
> +static struct attribute *node_targ_access_node_attrs[] = {
> +       NULL,
> +};
> +
> +static const struct attribute_group initiators = {
> +       .name   = "initiators",
> +       .attrs  = node_init_access_node_attrs,
> +};
> +
> +static const struct attribute_group targets = {
> +       .name   = "targets",
> +       .attrs  = node_targ_access_node_attrs,
> +};
> +
> +static const struct attribute_group *node_access_node_groups[] = {
> +       &initiators,
> +       &targets,
> +       NULL,
> +};
> +
> +static void node_remove_accesses(struct node *node)
> +{
> +       struct node_access_nodes *c, *cnext;
> +
> +       list_for_each_entry_safe(c, cnext, &node->access_list, list_node) {
> +               list_del(&c->list_node);
> +               device_unregister(&c->dev);
> +       }
> +}
> +
> +static void node_access_release(struct device *dev)
> +{
> +       kfree(to_access_nodes(dev));
> +}
> +
> +static struct node_access_nodes *node_init_node_access(struct node *node,
> +                                                      unsigned access)
> +{
> +       struct node_access_nodes *access_node;
> +       struct device *dev;
> +
> +       list_for_each_entry(access_node, &node->access_list, list_node)
> +               if (access_node->access == access)
> +                       return access_node;
> +
> +       access_node = kzalloc(sizeof(*access_node), GFP_KERNEL);
> +       if (!access_node)
> +               return NULL;
> +
> +       access_node->access = access;
> +       dev = &access_node->dev;
> +       dev->parent = &node->dev;
> +       dev->release = node_access_release;
> +       dev->groups = node_access_node_groups;
> +       if (dev_set_name(dev, "access%u", access))
> +               goto free;
> +
> +       if (device_register(dev))
> +               goto free_name;
> +
> +       pm_runtime_no_callbacks(dev);
> +       list_add_tail(&access_node->list_node, &node->access_list);
> +       return access_node;
> +free_name:
> +       kfree_const(dev->kobj.name);
> +free:
> +       kfree(access_node);
> +       return NULL;
> +}
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>                         struct device_attribute *attr, char *buf)
> @@ -340,7 +429,7 @@ static int register_node(struct node *node, int num)
>  void unregister_node(struct node *node)
>  {
>         hugetlb_unregister_node(node);          /* no-op, if memoryless node */
> -
> +       node_remove_accesses(node);
>         device_unregister(&node->dev);
>  }
>
> @@ -372,6 +461,56 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
>                                  kobject_name(&node_devices[nid]->dev.kobj));
>  }
>
> +/**
> + * register_memory_node_under_compute_node - link memory node to its compute
> + *                                          node for a given access class.
> + * @mem_node:  Memory node number
> + * @cpu_node:  Cpu  node number
> + * @access:    Access class to register
> + *
> + * Description:
> + *     For use with platforms that may have separate memory and compute nodes.
> + *     This function will export node relationships linking which memory
> + *     initiator nodes can access memory targets at a given ranked access
> + *     class.
> + */
> +int register_memory_node_under_compute_node(unsigned int mem_nid,
> +                                           unsigned int cpu_nid,
> +                                           unsigned access)
> +{
> +       struct node *init_node, *targ_node;
> +       struct node_access_nodes *initiator, *target;
> +       int ret;
> +
> +       if (!node_online(cpu_nid) || !node_online(mem_nid))
> +               return -ENODEV;
> +
> +       init_node = node_devices[cpu_nid];
> +       targ_node = node_devices[mem_nid];
> +       initiator = node_init_node_access(init_node, access);
> +       target = node_init_node_access(targ_node, access);
> +       if (!initiator || !target)
> +               return -ENOMEM;
> +
> +       ret = sysfs_add_link_to_group(&initiator->dev.kobj, "targets",
> +                                     &targ_node->dev.kobj,
> +                                     dev_name(&targ_node->dev));
> +       if (ret)
> +               return ret;
> +
> +       ret = sysfs_add_link_to_group(&target->dev.kobj, "initiators",
> +                                     &init_node->dev.kobj,
> +                                     dev_name(&init_node->dev));
> +       if (ret)
> +               goto err;
> +
> +       return 0;
> + err:
> +       sysfs_remove_link_from_group(&initiator->dev.kobj, "targets",
> +                                    dev_name(&targ_node->dev));
> +       return ret;
> +}
> +
>  int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
>  {
>         struct device *obj;
> @@ -580,6 +719,7 @@ int __register_one_node(int nid)
>                         register_cpu_under_node(cpu, nid);
>         }
>
> +       INIT_LIST_HEAD(&node_devices[nid]->access_list);
>         /* initialize work queue for memory hot plug */
>         init_node_hugetlb_work(nid);
>
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 257bb3d6d014..bb288817ed33 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -17,10 +17,12 @@
>
>  #include <linux/device.h>
>  #include <linux/cpumask.h>
> +#include <linux/list.h>
>  #include <linux/workqueue.h>
>
>  struct node {
>         struct device   dev;
> +       struct list_head access_list;
>
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>         struct work_struct      node_work;
> @@ -75,6 +77,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>                                            unsigned long phys_index);
>
> +extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> +                                                  unsigned int cpu_nid,
> +                                                  unsigned access);
> +
>  #ifdef CONFIG_HUGETLBFS
>  extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
>                                          node_registration_func_t unregister);
> --
> 2.14.4
>

