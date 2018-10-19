Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE51A6B0006
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 02:30:56 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y6-v6so1733082wmc.4
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:30:56 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t4-v6si20439739wrg.333.2018.10.18.23.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 23:30:55 -0700 (PDT)
Date: Fri, 19 Oct 2018 08:30:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] userfaultfd: disable irqs when taking the waitqueue
 lock
Message-ID: <20181019063054.GA28667@lst.de>
References: <20181018154101.18750-1-hch@lst.de> <20181018155611.42b9977ba08419b7869619c5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018155611.42b9977ba08419b7869619c5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 03:56:11PM -0700, Andrew Morton wrote:
> On Thu, 18 Oct 2018 17:41:01 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > userfaultfd contains howe-grown locking of the waitqueue lock,
> > and does not disable interrupts.  This relies on the fact that
> > no one else takes it from interrupt context and violates an
> > invariat of the normal waitqueue locking scheme.  With aio poll
> > it is easy to trigger other locks that disable interrupts (or
> > are called from interrupt context).
> 
> So...  this is needed in 4.19.x but not earlier?  Or something else?

Yes.
