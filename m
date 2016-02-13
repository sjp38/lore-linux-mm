Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3A26B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 00:12:20 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id wb13so150451330obb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 21:12:20 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id np10si2025115oeb.30.2016.02.12.21.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 21:12:18 -0800 (PST)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 12 Feb 2016 22:12:18 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B1265C40007
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 22:00:25 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1D5CFmW29622388
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 22:12:15 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1D5CFl8018994
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 22:12:15 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 02/29] powerpc/mm: Split pgtable types to separate header
In-Reply-To: <20160212025238.GC13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1454923241-6681-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160212025238.GC13831@oak.ozlabs.ibm.com>
Date: Sat, 13 Feb 2016 10:42:11 +0530
Message-ID: <87ziv5qjmc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:14PM +0530, Aneesh Kumar K.V wrote:
>> We remove real_pte_t out of STRICT_MM_TYPESCHECK. We will later add
>> a radix variant that is big endian
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> It looks like most of what this patch does is move a bunch of
> definitions from page.h to a new pgtable-types.h.  What is the
> motivation for this?  Is the code identical (pure code movement) or do
> you make changes along the way, and if so, what and why?

The motivation is to assist in addition of a big endian page table format later. 

>
> What exactly are you doing with real_pte_t and why?

Want to avoint STRICT_MM_TYPESCHECK related #ifdef around real_pte_t. I
can split that into a separate patch and keep this patch strictly code
movement.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
