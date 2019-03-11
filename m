Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B5BCC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38CD620657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:39:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38CD620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C50ED8E0019; Mon, 11 Mar 2019 07:39:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDB228E0002; Mon, 11 Mar 2019 07:39:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7B5B8E0019; Mon, 11 Mar 2019 07:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F67F8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:39:05 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b10so2612919oti.21
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:39:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=l4YjRjv3258twz4c3b5mUzVzcxfsg3TmotOA5VDlMTM=;
        b=okZRrzcoHM9T2zgw3xtDg68HjtrJ5EzCQKRHEzeEdobxDHXYwvG55SaGl+/WotE0on
         L1RZzz1AY7hiekRvIgIHCl78/VZsDACiOneNNdRIKKMz5zLjGsGaNhSSA0kxdWThZ6FJ
         k9uUW40DfDIl+TphxmVSPBOkbhaTT+Qcdj02YYrQS3BBnzbAsDk9AvOgWrawY80KS1Cd
         nRRUoRdvU0xxD+FFd4Rr/giPUJQP7JGwcXX2BxN3J/7FYF/rg/RgGtZNtC/185IQHy1c
         kp5twIqggnDtN9i3TOdBsK6I20dUJ84c1yLo+sllKdtWNF/jqhHPee2I1djZbDeUVcuJ
         72Mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWDI6mbA0OFxZciGtSZ2L1stTq9l/RzkfOK8+ZUadvfu8MYk/Wk
	VvNj5YdtftmxdF2GntGB6FdocP+JkipEQqDS41+JONbxLB8K+WC6HwjtdihdWtK0Qqlu8nps0Kj
	hLt1uPaPUJQnvS7FcBMbR/rF7dpCYavkUWNs59IjaFCE2MVtKoXzSFVTfOYi2n6Sk1A==
X-Received: by 2002:aca:428b:: with SMTP id p133mr15456287oia.123.1552304344990;
        Mon, 11 Mar 2019 04:39:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBuFjUIQqPQwORXXpKO7psXgO4zw7HWOeXofUmp7PedhrsHHfkyvS2nsUCXAL1FqFGZX7b
X-Received: by 2002:aca:428b:: with SMTP id p133mr15456234oia.123.1552304343536;
        Mon, 11 Mar 2019 04:39:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552304343; cv=none;
        d=google.com; s=arc-20160816;
        b=fVk1V8Euh7AfBtyKG16zCDL7XhE4NuvVM93UDEbyCNYYOkqNvk5Ijp3eNIC23e5WPh
         I2A4G4nuqlYSZXyisLh5YdG6lG5yju0Mfz8y+O5kMM9lGkJun3yRW6Mfwn0PtaUNEvw0
         5SwFT8Exhq0LL9jiDc9SUg6LTl7HZ0j/mGGKNTfuXedUcZGYnvTR7W3o4DbY/tJ8mtg8
         lZ27gvPGmBIUWcuY6/low/v5qfLyRVNejt8/AhreC6wgYypeRxsB2FsXObkLWfQRbjRU
         rI9Tlo4F9ZE/Gtv6Roof0s60tApPYO/c8wPJxPIeAkN9PZjy2uX3ncbEV+kwSDyreJbJ
         zSng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=l4YjRjv3258twz4c3b5mUzVzcxfsg3TmotOA5VDlMTM=;
        b=PsuZdgFUBUm6CY4Y44HRjY0NoKZ043+GmwYYFwapWbe1Lb+wnsTq+0/W2E8ieUD2m2
         hIA363rPLr4Rfhib+3BB9vSp0nj30FNlUuXLRy5OVUkPMT7pCWbGwsMnlRL0cVzieCrD
         EbF5Jr595AZPJbMkb5yWOIOkFqAJ9PpvNyLlDldaycdt2oAnsJYrqIz/ukf9zbmSc4Wr
         yoXEJ4J/QH5/j4FxzgIBCOjvpma+NocG8pk/BtjHsDNAfEIX9kxnWqt0rrgSl9eCIt9l
         5ONRv4dJ8JmDo6/hMmc3u5n4xBa5joJenl0SC1p1JaUWtfhHAOHu2lqng7n1MzrF+pW/
         PD0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b8si2364563oih.184.2019.03.11.04.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 04:39:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id DF62EE70C7920DBA5E05;
	Mon, 11 Mar 2019 19:38:58 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 19:38:54 +0800
Date: Mon, 11 Mar 2019 11:38:43 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 10/10] doc/mm: New documentation for memory
 performance
Message-ID: <20190311113843.00006b47@huawei.com>
In-Reply-To: <20190227225038.20438-11-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-11-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
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

On Wed, 27 Feb 2019 15:50:38 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Platforms may provide system memory where some physical address ranges
> perform differently than others, or is side cached by the system.
The magic 'side cached' term still here in the patch description, ideally
wants cleaning up.

> 
> Add documentation describing a high level overview of such systems and the
> perforamnce and caching attributes the kernel provides for applications
performance

> wishing to query this information.
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

A few comments inline. Mostly the weird corner cases that I miss understood
in one of the earlier versions of the code.

Whilst I think perhaps that one section could be tweaked a tiny bit I'm basically
happy with this if you don't want to.

Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

> ---
>  Documentation/admin-guide/mm/numaperf.rst | 164 ++++++++++++++++++++++++++++++
>  1 file changed, 164 insertions(+)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> 
> diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> new file mode 100644
> index 000000000000..d32756b9be48
> --- /dev/null
> +++ b/Documentation/admin-guide/mm/numaperf.rst
> @@ -0,0 +1,164 @@
> +.. _numaperf:
> +
> +=============
> +NUMA Locality
> +=============
> +
> +Some platforms may have multiple types of memory attached to a compute
> +node. These disparate memory ranges may share some characteristics, such
> +as CPU cache coherence, but may have different performance. For example,
> +different media types and buses affect bandwidth and latency.
> +
> +A system supports such heterogeneous memory by grouping each memory type
> +under different domains, or "nodes", based on locality and performance
> +characteristics.  Some memory may share the same node as a CPU, and others
> +are provided as memory only nodes. While memory only nodes do not provide
> +CPUs, they may still be local to one or more compute nodes relative to
> +other nodes. The following diagram shows one such example of two compute
> +nodes with local memory and a memory only node for each of compute node:
> +
> + +------------------+     +------------------+
> + | Compute Node 0   +-----+ Compute Node 1   |
> + | Local Node0 Mem  |     | Local Node1 Mem  |
> + +--------+---------+     +--------+---------+
> +          |                        |
> + +--------+---------+     +--------+---------+
> + | Slower Node2 Mem |     | Slower Node3 Mem |
> + +------------------+     +--------+---------+
> +
> +A "memory initiator" is a node containing one or more devices such as
> +CPUs or separate memory I/O devices that can initiate memory requests.
> +A "memory target" is a node containing one or more physical address
> +ranges accessible from one or more memory initiators.
> +
> +When multiple memory initiators exist, they may not all have the same
> +performance when accessing a given memory target. Each initiator-target
> +pair may be organized into different ranked access classes to represent
> +this relationship. 

This concept is a bit vague at the moment. Largely because only access0
is actually defined.  We should definitely keep a close eye on any others
that are defined in future to make sure this text is still valid.

I can certainly see it being used for different ideas of 'best' rather
than simply best and second best etc.

> The highest performing initiator to a given target
> +is considered to be one of that target's local initiators, and given
> +the highest access class, 0. Any given target may have one or more
> +local initiators, and any given initiator may have multiple local
> +memory targets.
> +
> +To aid applications matching memory targets with their initiators, the
> +kernel provides symlinks to each other. The following example lists the
> +relationship for the access class "0" memory initiators and targets, which is
> +the of nodes with the highest performing access relationship::
> +
> +	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
> +	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY

So this one perhaps needs a bit more description - I would put it after initiators
which precisely fits the description you have here now.

"targets contains those nodes for which this initiator is the best possible initiator."

which is subtly different form

"targets contains those nodes to which this node has the highest
performing access characteristics."

For example in my test case:
* 4 nodes with local memory and cpu, 1 node remote and equal distant from all of the
  initiators,

targets for the compute nodes contains both themselves and the remote node, to which
the characteristics are of course worse. As you point out before, we need to look
in 
node0/access0/targets/node0/access0/initiators 
node0/access0/targets/node4/access0/initiators 
to get the relevant characteristics and work out that node0 is 'nearer' itself
(obviously this is a bit of a silly case, but we could have no memory node0 and
be talking about node4 and node5.

I am happy with the actual interface, this is just a question about whether we can tweak
this text to be slightly clearer.

> +
> +	# symlinks -v /sys/devices/system/node/nodeY/access0/initiators/
> +	relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
> +
> +================
> +NUMA Performance
> +================
> +
> +Applications may wish to consider which node they want their memory to
> +be allocated from based on the node's performance characteristics. If
> +the system provides these attributes, the kernel exports them under the
> +node sysfs hierarchy by appending the attributes directory under the
> +memory node's access class 0 initiators as follows::
> +
> +	/sys/devices/system/node/nodeY/access0/initiators/
> +
> +These attributes apply only when accessed from nodes that have the
> +are linked under the this access's inititiators.
> +
> +The performance characteristics the kernel provides for the local initiators
> +are exported are as follows::
> +
> +	# tree -P "read*|write*" /sys/devices/system/node/nodeY/access0/initiators/
> +	/sys/devices/system/node/nodeY/access0/initiators/
> +	|-- read_bandwidth
> +	|-- read_latency
> +	|-- write_bandwidth
> +	`-- write_latency
> +
> +The bandwidth attributes are provided in MiB/second.
> +
> +The latency attributes are provided in nanoseconds.
> +
> +The values reported here correspond to the rated latency and bandwidth
> +for the platform.
> +
> +==========
> +NUMA Cache
> +==========
> +
> +System memory may be constructed in a hierarchy of elements with various
> +performance characteristics in order to provide large address space of
> +slower performing memory cached by a smaller higher performing memory. The
> +system physical addresses memory  initiators are aware of are provided
> +by the last memory level in the hierarchy. The system meanwhile uses
> +higher performing memory to transparently cache access to progressively
> +slower levels.
> +
> +The term "far memory" is used to denote the last level memory in the
> +hierarchy. Each increasing cache level provides higher performing
> +initiator access, and the term "near memory" represents the fastest
> +cache provided by the system.
> +
> +This numbering is different than CPU caches where the cache level (ex:
> +L1, L2, L3) uses the CPU-side view where each increased level is lower
> +performing. In contrast, the memory cache level is centric to the last
> +level memory, so the higher numbered cache level corresponds to  memory
> +nearer to the CPU, and further from far memory.
> +
> +The memory-side caches are not directly addressable by software. When
> +software accesses a system address, the system will return it from the
> +near memory cache if it is present. If it is not present, the system
> +accesses the next level of memory until there is either a hit in that
> +cache level, or it reaches far memory.
> +
> +An application does not need to know about caching attributes in order
> +to use the system. Software may optionally query the memory cache
> +attributes in order to maximize the performance out of such a setup.
> +If the system provides a way for the kernel to discover this information,
> +for example with ACPI HMAT (Heterogeneous Memory Attribute Table),
> +the kernel will append these attributes to the NUMA node memory target.
> +
> +When the kernel first registers a memory cache with a node, the kernel
> +will create the following directory::

Real nitpick but more precisely, "If relevant, the kernel..."  Otherwise
we say it's always there but then say it isn't below.

> +
> +	/sys/devices/system/node/nodeX/memory_side_cache/
> +
> +If that directory is not present, the system either does not not provide
> +a memory-side cache, or that information is not accessible to the kernel.
> +
> +The attributes for each level of cache is provided under its cache
> +level index::
> +
> +	/sys/devices/system/node/nodeX/memory_side_cache/indexA/
> +	/sys/devices/system/node/nodeX/memory_side_cache/indexB/
> +	/sys/devices/system/node/nodeX/memory_side_cache/indexC/
> +
> +Each cache level's directory provides its attributes. For example, the
> +following shows a single cache level and the attributes available for
> +software to query::
> +
> +	# tree sys/devices/system/node/node0/memory_side_cache/
> +	/sys/devices/system/node/node0/memory_side_cache/
> +	|-- index1
> +	|   |-- indexing
> +	|   |-- line_size
> +	|   |-- size
> +	|   `-- write_policy
> +
> +The "indexing" will be 0 if it is a direct-mapped cache, and non-zero
> +for any other indexed based, multi-way associativity.
> +
> +The "line_size" is the number of bytes accessed from the next cache
> +level on a miss.
> +
> +The "size" is the number of bytes provided by this cache level.
> +
> +The "write_policy" will be 0 for write-back, and non-zero for
> +write-through caching.
> +
> +========
> +See Also
> +========
> +.. [1] https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> +       Section 5.2.27


