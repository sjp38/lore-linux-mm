Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1D96B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 22:21:39 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id py5so236587173obc.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:21:39 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id me8si3513569oeb.26.2016.01.19.19.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 19:21:38 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id vt7so204666699obb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:21:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160119233028.GA22867@node.shutemov.name>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
	<20160119141430.8ff9c464.akpm@linux-foundation.org>
	<20160119233028.GA22867@node.shutemov.name>
Date: Wed, 20 Jan 2016 08:51:38 +0530
Message-ID: <CAAHN_R2q23-gN43j52X231k0Xs-D_x5KofEMGq_npdWCWVpuyA@mail.gmail.com>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On 20 January 2016 at 05:00, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> I doubt it can be very useful as it's unreliable: if two stacks are
> allocated end-to-end (which is not good idea, but still) it can only
> report [stack:XXX] for the first one as they are merged into one VMA.
> Any other anon VMA merged with the stack will be also claimed as stack,
> which is not always correct.

It is quite uncommon because you will always have an intervening guard
page that separates the two stack vmas.  To have the vmas merge, you
will have to disable guard pages which is an even worse idea.

A more relevant argument about its unreliability is context changes
due to makecontext/setcontext, which could momentarily show the heap
or some other arbitrary vma as a stack.

Siddhesh
-- 
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
