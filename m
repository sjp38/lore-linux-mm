Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21A1B6B027C
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 00:15:03 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r51so22787209qtj.17
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 21:15:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h9si4214601qti.441.2017.12.22.21.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 21:14:57 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBN5EJQf048406
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 00:14:56 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f1cdsx5ht-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 00:14:56 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 23 Dec 2017 05:14:54 -0000
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
 <5d7df981-69c2-e371-f48d-13c418fff134@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sat, 23 Dec 2017 10:44:34 +0530
MIME-Version: 1.0
In-Reply-To: <5d7df981-69c2-e371-f48d-13c418fff134@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <3bffaacf-e927-fb06-4dd0-3821f6f82dad@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 12/22/2017 10:43 PM, Dave Hansen wrote:
> On 12/21/2017 07:09 PM, Anshuman Khandual wrote:
>> I had presented a proposal for NUMA redesign in the Plumbers Conference this
>> year where various memory devices with different kind of memory attributes
>> can be represented in the kernel and be used explicitly from the user space.
>> Here is the link to the proposal if you feel interested. The proposal is
>> very intrusive and also I dont have a RFC for it yet for discussion here.
> I think that's the best reason to "re-use NUMA" for this: it's _not_
> intrusive.
> 
> Also, from an x86 perspective, these HMAT systems *will* be out there.
> Old versions of Linux *will* see different types of memory as separate
> NUMA nodes.  So, if we are going to do something different, it's going
> to be interesting to un-teach those systems about using the NUMA APIs
> for this.  That ship has sailed.

I understand the need to fetch these details from ACPI/DT for
applications to target these distinct memory only NUMA nodes.
This can be done by parsing from platform specific values from
/proc/acpi/ or /proc/device-tree/ interfaces. This can be a
short term solution before NUMA redesign can be figured out.
But adding generic devices like "hmat" in the /sys/devices/
path which will be locked for good, seems problematic.
   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
