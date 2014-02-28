Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 26E346B0072
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 04:04:51 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so489076pdj.27
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 01:04:50 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id yc8si1255210pbc.187.2014.02.28.01.04.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 01:04:42 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Feb 2014 19:04:40 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id F35B73578053
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 20:04:37 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1S8ioXG3080534
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 19:44:50 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1S94b6U008569
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 20:04:37 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
In-Reply-To: <CAJnKYQkVziWMmCL=rTakSA4955VMvFnaFtFdmexQAKUfTuVv_Q@mail.gmail.com>
References: <1391563546-26052-1-git-send-email-pingfank@linux.vnet.ibm.com> <20140213152009.b16a30d2a5b5c5706fc8952a@linux-foundation.org> <87k3cifgzz.fsf@linux.vnet.ibm.com> <20140227154104.4e3572f1d9e2692d431d1a4e@linux-foundation.org> <877g8fn8qw.fsf@linux.vnet.ibm.com> <CAJnKYQkVziWMmCL=rTakSA4955VMvFnaFtFdmexQAKUfTuVv_Q@mail.gmail.com>
Date: Fri, 28 Feb 2014 14:34:31 +0530
Message-ID: <871tynmwv4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liu ping fan <qemulist@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

liu ping fan <qemulist@gmail.com> writes:

> On Fri, Feb 28, 2014 at 12:47 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> Andrew Morton <akpm@linux-foundation.org> writes:
>>
> Thanks for sending V2.  Since the ppc machine env is changed by
> others, I am blocking on setting up the env for re-test this patch.
> And not send out it quickly.

I sent an updated v3 also taking care of xchg

http://article.gmane.org/gmane.linux.kernel/1657613

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
