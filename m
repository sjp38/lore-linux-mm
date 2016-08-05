Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6B06B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:39:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so21149957wml.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:39:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id rx6si17233887wjc.193.2016.08.05.00.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 00:36:32 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u757XpDw143075
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 03:36:31 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkapgv6w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 05 Aug 2016 03:36:30 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 5 Aug 2016 17:36:28 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 845682CE8056
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 17:36:26 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u757aQ2k26607866
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 17:36:26 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u757aP4K011920
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 17:36:26 +1000
Date: Fri, 5 Aug 2016 13:06:21 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 1/2] mm/page_alloc: Replace set_dma_reserve to
 set_memory_reserve
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20160805064747.GN2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160805064747.GN2799@techsingularity.net>
Message-Id: <20160805073621.GG11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

* Mel Gorman <mgorman@techsingularity.net> [2016-08-05 07:47:47]:

> On Thu, Aug 04, 2016 at 10:42:08PM +0530, Srikar Dronamraju wrote:
> > Expand the scope of the existing dma_reserve to accommodate other memory
> > reserves too. Accordingly rename variable dma_reserve to
> > nr_memory_reserve.
> > 
> > set_memory_reserve also takes a new parameter that helps to identify if
> > the current value needs to be incremented.
> > 
> 
> I think the parameter is ugly and it should have been just
> inc_memory_reserve but at least it works.
> 

Yes while the parameter is definitely ugly, the only other use
case in arch/x86/kernel/e820.c seems to be written with an intention to
set to an absolute value.

It was "set_dma_reserve(nr_pages - nr_free_pages)". Both of them
nr_pages and nr_free_pages are calculated after walking through the mem
blocks. I didnt want to take a chance where someother code path also
starts to set reserve value and then the code in e820.c just increments
it.

However if you still feel strongly about using inc_memory_reserve than
set_memory_reserve, I will respin.


-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
