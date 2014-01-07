Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 40EAF6B0037
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:19:16 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so18654903pdj.8
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:19:15 -0800 (PST)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id ll1si38434944pab.115.2014.01.06.18.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 18:19:14 -0800 (PST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 12:19:09 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BA3243578052
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 13:19:06 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s072Irwv1573242
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 13:18:53 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s072J5X3022398
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 13:19:05 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 1/2] powerpc: mm: Move ppc64 page table range definitions to separate header
In-Reply-To: <1389050101.12906.13.camel@pasglop>
References: <1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1389050101.12906.13.camel@pasglop>
Date: Tue, 07 Jan 2014 07:49:01 +0530
Message-ID: <87mwj8wn3e.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Mon, 2014-01-06 at 14:33 +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This avoid mmu-hash64.h including pagetable-ppc64.h. That inclusion
>> cause issues like
>
> I don't like this. We have that stuff split into too many includes
> already it's a mess.

I understand. Let me know, if you have any suggestion on cleaning that
up. I can do that.

>
> Why do we need to include it from mmu*.h ?

in mmu-hash64.h added by me via 78f1dbde9fd020419313c2a0c3b602ea2427118f

/*
 * This is necessary to get the definition of PGTABLE_RANGE which we
 * need for various slices related matters. Note that this isn't the
 * complete pgtable.h but only a portion of it.
 */
#include <asm/pgtable-ppc64.h>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
