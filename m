Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7B26B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:25:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c14so3665734pgn.11
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 08:25:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f14si181516pgu.787.2017.07.19.08.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 08:25:14 -0700 (PDT)
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <dc224433-3d09-8f2e-d278-fee98ada2afc@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0e72ed92-75d0-3fe1-0ab7-ffa069d11b46@intel.com>
Date: Wed, 19 Jul 2017 08:25:13 -0700
MIME-Version: 1.0
In-Reply-To: <dc224433-3d09-8f2e-d278-fee98ada2afc@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 07/19/2017 02:48 AM, Bob Liu wrote:
>> Option 2: Provide the user with HMAT performance data directly in
>> sysfs, allowing applications to directly access it without the need
>> for the library and daemon.
>> 
> Is it possible to do the memory allocation automatically by the
> kernel and transparent to users? It sounds like unreasonable that
> most users should aware this detail memory topology.

It's possible, but I'm not sure this is something we automatically want
to see added to the kernel.

I look at it like NUMA.  We have lots of details available about how
things are connected.  But, "most users" are totally unaware of this.
We give them decent default policies and the ones that need more can do
so with the NUMA APIs.

These patches provide the framework to help users/apps who *do* care and
want to make intelligent, topology-aware decisions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
