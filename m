Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id AA61C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 22:17:40 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id is5so204514186obc.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:17:40 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id tl9si3001711oec.45.2016.01.19.19.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 19:17:39 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id p187so188775193oia.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:17:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160119141430.8ff9c464.akpm@linux-foundation.org>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
	<20160119141430.8ff9c464.akpm@linux-foundation.org>
Date: Wed, 20 Jan 2016 08:47:39 +0530
Message-ID: <CAAHN_R2CFYsSSU_Qr-_cE+9-=OqDOa88annh9uA1TymuJncL8A@mail.gmail.com>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On 20 January 2016 at 03:44, Andrew Morton <akpm@linux-foundation.org> wrote:
> Any thoughts on the obvious back-compatibility concerns?  ie, why did
> Siddhesh implement this in the first place?  My bad for not ensuring
> that the changelog told us this.
>
> https://lkml.org/lkml/2012/1/14/25 has more info:
>
> : Memory mmaped by glibc for a thread stack currently shows up as a
> : simple anonymous map, which makes it difficult to differentiate between
> : memory usage of the thread on stack and other dynamic allocation.
> : Since glibc already uses MAP_STACK to request this mapping, the
> : attached patch uses this flag to add additional VM_STACK_FLAGS to the
> : resulting vma so that the mapping is treated as a stack and not any
> : regular anonymous mapping.  Also, one may use vm_flags to decide if a
> : vma is a stack.
>
> But even that doesn't really tell us what the actual *value* of the
> patch is to end-users.

The end users needed a way to identify thread stacks programmatically
and there wasn't a way to do that.  I'm afraid I no longer remember
(or have access to the resources that would aid my memory since I
changed employers) the details of their requirement.  However, I did
do this on my own time because I thought it was an interesting project
for me and nobody really gave any feedback then as to its utility, so
as far as I am concerned you could roll back the main thread maps
information since the information is available in the thread-specific
files.

Siddhesh
-- 
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
