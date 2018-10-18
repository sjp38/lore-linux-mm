Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4728B6B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 18:56:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7-v6so14617203pfj.6
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 15:56:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i72-v6si22382251pfe.224.2018.10.18.15.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 15:56:15 -0700 (PDT)
Date: Thu, 18 Oct 2018 15:56:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] userfaultfd: disable irqs when taking the waitqueue
 lock
Message-Id: <20181018155611.42b9977ba08419b7869619c5@linux-foundation.org>
In-Reply-To: <20181018154101.18750-1-hch@lst.de>
References: <20181018154101.18750-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org

On Thu, 18 Oct 2018 17:41:01 +0200 Christoph Hellwig <hch@lst.de> wrote:

> userfaultfd contains howe-grown locking of the waitqueue lock,
> and does not disable interrupts.  This relies on the fact that
> no one else takes it from interrupt context and violates an
> invariat of the normal waitqueue locking scheme.  With aio poll
> it is easy to trigger other locks that disable interrupts (or
> are called from interrupt context).

So...  this is needed in 4.19.x but not earlier?  Or something else?
