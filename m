Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2F9F6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 16:23:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so136126843wmg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 13:23:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ct5si6661419wjc.177.2016.10.04.13.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 13:23:45 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u94KNalc087208
	for <linux-mm@kvack.org>; Tue, 4 Oct 2016 16:23:44 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25vkdkg09t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Oct 2016 16:23:44 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 4 Oct 2016 16:23:43 -0400
Date: Tue, 4 Oct 2016 15:23:36 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when
 using movable_node
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
 <1474924351.2857.255.camel@kernel.crashing.org>
 <20160927001413.o72fqpfsnsxpu5qq@arbab-laptop>
 <e161a34e-4e58-42f5-49ed-3e7913189eb9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <e161a34e-4e58-42f5-49ed-3e7913189eb9@gmail.com>
Message-Id: <20161004202336.cp7o3772ygfn4o3k@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 04, 2016 at 11:48:30AM +1100, Balbir Singh wrote:
>On 27/09/16 10:14, Reza Arbab wrote:
>> Right. To be clear, the background info I put in the commit log 
>> refers to x86, where the SRAT can describe movable nodes which exist 
>> at boot.  They're trying to avoid allocations from those nodes before 
>> they've been identified.
>>
>> On power, movable nodes can only exist via hotplug, so that scenario 
>> can't happen. We can immediately go back to top-down allocation. That 
>> is the missing call being added in the patch.
>
>Can we fix cmdline_parse_movable_node() to do the right thing? I 
>suspect that code is heavily x86 only in the sense that no other arch 
>needs it.

Good idea. We could change it so things only go bottom-up on x86 in the 
first place.

A nice consequence is that CONFIG_MOVABLE_NODE would then basically be 
usable on any platform with memory hotplug, not just PPC64 and X86_64.

I'll see if I can move the relevant code into an arch_*() call or 
otherwise factor it out.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
