Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 38D8F6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 10:25:33 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 16 May 2013 19:49:48 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 08F7EE0055
	for <linux-mm@kvack.org>; Thu, 16 May 2013 19:57:52 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4GEPJA13211654
	for <linux-mm@kvack.org>; Thu, 16 May 2013 19:55:19 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4GEPNYU021221
	for <linux-mm@kvack.org>; Fri, 17 May 2013 00:25:23 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t pointer
In-Reply-To: <20130516131804.GO5181@redhat.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <871u9b56t2.fsf@linux.vnet.ibm.com> <20130513141357.GL27980@redhat.com> <87y5bj3pnc.fsf@linux.vnet.ibm.com> <87txm6537l.fsf@linux.vnet.ibm.com> <20130516131804.GO5181@redhat.com>
Date: Thu, 16 May 2013 19:55:23 +0530
Message-ID: <87bo8bxar0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

Andrea Arcangeli <aarcange@redhat.com> writes:

> Hi Aneesh,
>
> On Mon, May 13, 2013 at 08:36:38PM +0530, Aneesh Kumar K.V wrote:
>> https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-May/106406.html
>
> You need ACCESS_ONCE() in all "pgd = ACCESS_ONCE(*pgdp)", "pud =
> ACCESS_ONCE(*pudp)" otherwise the compiler could decide your change is
> a noop.

Will do. I guess we have similar one for x86 here 

http://article.gmane.org/gmane.linux.kernel/1483617

May be ppc64 gup walk also need similar changes ?

>
> I think you could remove the #ifdef CONFIG_TRANSPARENT_HUGEPAGE too.

That was becaue i had pte_pmd available only with that config. I will
see if we can fix that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
