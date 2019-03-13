Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22266C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C662820854
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:16:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C662820854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5285F8E000C; Wed, 13 Mar 2019 19:16:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AE858E0001; Wed, 13 Mar 2019 19:16:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 377408E000C; Wed, 13 Mar 2019 19:16:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id F24348E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:16:08 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id c186so1519086oih.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:16:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=k6s7+MyaJ7lmyZgaX8+pCT5G3jU2yjbRiWoxLQGD/hc=;
        b=iYhnO3aCnNGCd7Pu66pmKAdmZwJ527jj6J/pigFgoCs5gk0y7mYXj5aL4jMPSrUQ+Z
         44xXEOi/veGF/3QRV0Dtky5ciz1aeqdwgFzFzECOtVk3fvTMiQ+KkLVB0STtZW0vQIkM
         SU+7iTdffz8GanoN3V/qPMwgofXtm5IWnlEcdlghY5vB2iN67MCTSnLCN/o1D1M5fs/X
         FB1jlcuJcqhBR2xAjVWjYLgwgO0b6NUT3SKVIxlmWAHzS0hYe0eOTpGTWw9R5mjXvKQ0
         LPirdY2E0RjPpGU8BSrj4h1/4qSx2eJ/XVu7C62dNE4EBsocnLaoE7uzRD4SOxxHovM7
         ogZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXp1y6Nvh2Vx7JfeUHYzsZhdPRS9bjFJD4iMT4LY5wltBm6XRBn
	PfeX1+57Vf8oo7TjQKtnfrQZpE7nyxb8foBIo19aCRh3C4CJHR1bGQKptmVAW5YnUsNI2gDA+6Y
	Tf+nVQOx91lAZB0rbS7njrLQs/1tBhWJIctB/cZvxw98jt+/p4jayDI80kP42O609QuTpG/s8pr
	ONol9n/e3fruOPhw3Fuq+vX/BRO1Td4Zib1DvKgl1fELeW2X8mYsVNFm5AeJ8BiJkGPFhZl2kgY
	+FMV8k7bJZZA219x4XQODjKaXI8VHoeT8S0pUXHEgPH9TmWsQ7NiKmIAdnhO96RxoEZYGWohtkH
	F7B8RngAf37VKWXzHAnKW+ZhpZ640fwW5JCvwOLmSTUbAmLr9dSeTdUpsid7/tTY1j8cyTVZ9Q=
	=
X-Received: by 2002:a9d:745a:: with SMTP id p26mr29289823otk.206.1552518968688;
        Wed, 13 Mar 2019 16:16:08 -0700 (PDT)
X-Received: by 2002:a9d:745a:: with SMTP id p26mr29289786otk.206.1552518967718;
        Wed, 13 Mar 2019 16:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552518967; cv=none;
        d=google.com; s=arc-20160816;
        b=frzjWQvR8CNJ/mrCpHDhVSUl6Xl0tL6QWuF7gsy1N64Fi5weA/ljQSvaXfloTKt/Xf
         7vEtuDAeEXgKpVk9g/bm+NWoh+0YyCaYdcd89DV0eHlYWSfytxxY0O4c5EvUjbzo3Dye
         2CBTe+/R2T+WaaDmjWt2bsE2G79hGo+HOM94LbysP9BErAQqyKvDzZQxyKTMfeU9Hp/A
         16NHcOlAk622Z7L2U3Plfs9k2ai7Vnj/uJgqTUXYBuqkhHc1ljXAzqnUmSGSkyxJLRtW
         v0VufszPD08D0JeNBLGIL1keJpp2ygwkncmbEAgiyfK5fHfpPb1303TZ8KXi94xP6nab
         ElbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=k6s7+MyaJ7lmyZgaX8+pCT5G3jU2yjbRiWoxLQGD/hc=;
        b=blAG/aEFkEn/7aP+zKodXTtPSyKD62rT6Mdpe85Bi2jRXN61dUHuKX66Pre0agv+N2
         Ymh2epBx0NvtDJ1CTqn0vc2F/MLtk5Qk8wmygeXJqdZCz57YfOJlkzHwXV36CbFWjgqr
         SRqkd1/hknqvrsP1tLowQfzPahNkbGy/jHtVroeIeTpbwjzBBYlbrXazP5vE6pEENY6D
         xu5EHyBVJlBJU8+q/IVZIuomNlsX5Fd9Z+C4gsKRiPVRo7D+6Ly/uUnmDhqz1Qa84rsR
         EOWHPBnJaXv0SIp1LuZ0N5CiJrajH/brec0TuC1WaEWA46MhCiMOnhuT+auHa+GlZey4
         KVMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor3675920otp.39.2019.03.13.16.16.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 16:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwJTiVbUw+KaGr1iWt5iss9/Dh43pvrsGXfnCMsny/0STPSQWaYtMvT5eiQMOx3+q2eWgE2DV7ku/NOrOBQbI8=
X-Received: by 2002:a9d:7a58:: with SMTP id z24mr1122847otm.244.1552518967328;
 Wed, 13 Mar 2019 16:16:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190311205606.11228-1-keith.busch@intel.com> <20190311205606.11228-6-keith.busch@intel.com>
In-Reply-To: <20190311205606.11228-6-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 14 Mar 2019 00:15:56 +0100
Message-ID: <CAJZ5v0hun3u8wswpM93GPW6M+VZ4u9Txz5C1JuG1D7h3uP4_2w@mail.gmail.com>
Subject: Re: [PATCHv8 05/10] node: Add heterogenous memory access attributes
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
> Heterogeneous memory systems provide memory nodes with different latency
> and bandwidth performance attributes. Provide a new kernel interface
> for subsystems to register the attributes under the memory target
> node's initiator access class. If the system provides this information,
> applications may query these attributes when deciding which node to
> request memory.
>
> The following example shows the new sysfs hierarchy for a node exporting
> performance attributes:
>
>   # tree -P "read*|write*"/sys/devices/system/node/nodeY/accessZ/initiators/
>   /sys/devices/system/node/nodeY/accessZ/initiators/
>   |-- read_bandwidth
>   |-- read_latency
>   |-- write_bandwidth
>   `-- write_latency
>
> The bandwidth is exported as MB/s and latency is reported in
> nanoseconds. The values are taken from the platform as reported by the
> manufacturer.
>
> Memory accesses from an initiator node that is not one of the memory's
> access "Z" initiator nodes linked in the same directory may observe
> different performance than reported here. When a subsystem makes use
> of this interface, initiators of a different access number may not have
> the same performance relative to initiators in other access numbers, or
> omitted from the any access class' initiators.
>
> Descriptions for memory access initiator performance access attributes
> are added to sysfs stable documentation.
>
> Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++
>  drivers/base/Kconfig                        |  8 ++++
>  drivers/base/node.c                         | 59 +++++++++++++++++++++++++++++
>  include/linux/node.h                        | 26 +++++++++++++
>  4 files changed, 121 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 433bcc04e542..735a40a3f9b2 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -114,3 +114,31 @@ Contact:   Keith Busch <keith.busch@intel.com>
>  Description:
>                 The directory containing symlinks to memory targets that
>                 this initiator node has class "Y" access.
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/read_bandwidth
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's read bandwidth in MB/s when accessed from
> +               nodes found in this access class's linked initiators.
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/read_latency
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's read latency in nanoseconds when accessed
> +               from nodes found in this access class's linked initiators.
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/write_bandwidth
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's write bandwidth in MB/s when accessed from
> +               found in this access class's linked initiators.
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/write_latency
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's write latency in nanoseconds when access
> +               from nodes found in this class's linked initiators.
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 059700ea3521..a7438a58c250 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
>           unusable. You should say N here unless you are explicitly looking to
>           test this functionality.
>
> +config HMEM_REPORTING
> +       bool
> +       default n
> +       depends on NUMA
> +       help
> +         Enable reporting for heterogenous memory access attributes under
> +         their non-uniform memory nodes.
> +
>  source "drivers/base/test/Kconfig"
>
>  config SYS_HYPERVISOR
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 6f4097680580..2de546a040a5 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -71,6 +71,9 @@ struct node_access_nodes {
>         struct device           dev;
>         struct list_head        list_node;
>         unsigned                access;
> +#ifdef CONFIG_HMEM_REPORTING
> +       struct node_hmem_attrs  hmem_attrs;
> +#endif
>  };
>  #define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
>
> @@ -148,6 +151,62 @@ static struct node_access_nodes *node_init_node_access(struct node *node,
>         return NULL;
>  }
>
> +#ifdef CONFIG_HMEM_REPORTING
> +#define ACCESS_ATTR(name)                                                 \
> +static ssize_t name##_show(struct device *dev,                            \
> +                          struct device_attribute *attr,                  \
> +                          char *buf)                                      \
> +{                                                                         \
> +       return sprintf(buf, "%u\n", to_access_nodes(dev)->hmem_attrs.name); \
> +}                                                                         \
> +static DEVICE_ATTR_RO(name);
> +
> +ACCESS_ATTR(read_bandwidth)
> +ACCESS_ATTR(read_latency)
> +ACCESS_ATTR(write_bandwidth)
> +ACCESS_ATTR(write_latency)
> +
> +static struct attribute *access_attrs[] = {
> +       &dev_attr_read_bandwidth.attr,
> +       &dev_attr_read_latency.attr,
> +       &dev_attr_write_bandwidth.attr,
> +       &dev_attr_write_latency.attr,
> +       NULL,
> +};
> +
> +/**
> + * node_set_perf_attrs - Set the performance values for given access class
> + * @nid: Node identifier to be set
> + * @hmem_attrs: Heterogeneous memory performance attributes
> + * @access: The access class the for the given attributes
> + */
> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned access)
> +{
> +       struct node_access_nodes *c;
> +       struct node *node;
> +       int i;
> +
> +       if (WARN_ON_ONCE(!node_online(nid)))
> +               return;
> +
> +       node = node_devices[nid];
> +       c = node_init_node_access(node, access);
> +       if (!c)
> +               return;
> +
> +       c->hmem_attrs = *hmem_attrs;
> +       for (i = 0; access_attrs[i] != NULL; i++) {
> +               if (sysfs_add_file_to_group(&c->dev.kobj, access_attrs[i],
> +                                           "initiators")) {
> +                       pr_info("failed to add performance attribute to node %d\n",
> +                               nid);
> +                       break;
> +               }
> +       }
> +}
> +#endif
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>                         struct device_attribute *attr, char *buf)
> diff --git a/include/linux/node.h b/include/linux/node.h
> index bb288817ed33..4139d728f8b3 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -20,6 +20,32 @@
>  #include <linux/list.h>
>  #include <linux/workqueue.h>
>
> +/**
> + * struct node_hmem_attrs - heterogeneous memory performance attributes
> + *
> + * @read_bandwidth:    Read bandwidth in MB/s
> + * @write_bandwidth:   Write bandwidth in MB/s
> + * @read_latency:      Read latency in nanoseconds
> + * @write_latency:     Write latency in nanoseconds
> + */
> +struct node_hmem_attrs {
> +       unsigned int read_bandwidth;
> +       unsigned int write_bandwidth;
> +       unsigned int read_latency;
> +       unsigned int write_latency;
> +};
> +
> +#ifdef CONFIG_HMEM_REPORTING
> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned access);
> +#else
> +static inline void node_set_perf_attrs(unsigned int nid,
> +                                      struct node_hmem_attrs *hmem_attrs,
> +                                      unsigned access)
> +{
> +}
> +#endif
> +
>  struct node {
>         struct device   dev;
>         struct list_head access_list;
> --
> 2.14.4
>

