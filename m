Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 66F296B0038
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 12:20:48 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so690239pdj.0
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 09:20:48 -0800 (PST)
Received: from e28smtp04.in.ibm.com ([122.248.162.4])
        by mx.google.com with ESMTPS id vv1si2305948pbc.109.2014.12.03.09.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 09:20:46 -0800 (PST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 3 Dec 2014 22:50:40 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7306B125804F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 22:50:55 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB3HKTGh63832192
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 22:50:30 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB3HKZDP005080
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 22:50:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
In-Reply-To: <20141203155242.GE6043@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de> <1416578268-19597-4-git-send-email-mgorman@suse.de> <1417473762.7182.8.camel@kernel.crashing.org> <87k32ah5q3.fsf@linux.vnet.ibm.com> <1417551115.27448.7.camel@kernel.crashing.org> <87lhmobvuu.fsf@linux.vnet.ibm.com> <20141203155242.GE6043@suse.de>
Date: Wed, 03 Dec 2014 22:50:35 +0530
Message-ID: <87d280bqfw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

Mel Gorman <mgorman@suse.de> writes:

> On Wed, Dec 03, 2014 at 08:53:37PM +0530, Aneesh Kumar K.V wrote:
>> Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:
>> 
>> > On Tue, 2014-12-02 at 12:57 +0530, Aneesh Kumar K.V wrote:
>> >> Now, hash_preload can possibly insert an hpte in hash page table even if
>> >> the access is not allowed by the pte permissions. But i guess even that
>> >> is ok. because we will fault again, end-up calling hash_page_mm where we
>> >> handle that part correctly.
>> >
>> > I think we need a test case...
>> >
>> 
>> I ran the subpageprot test that Paul had written. I modified it to ran
>> with selftest. 
>> 
>
> It's implied but can I assume it passed? 

Yes.

-bash-4.2# ./subpage_prot 
test: subpage_prot
tags: git_version:v3.17-rc3-13511-g0cd3756
allocated malloc block of 0x4000000 bytes at 0x0x3fffb0d10000
testing malloc block...
OK
success: subpage_prot
-bash-4.2# 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
