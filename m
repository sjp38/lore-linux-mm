Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f182.google.com (mail-gg0-f182.google.com [209.85.161.182])
	by kanga.kvack.org (Postfix) with ESMTP id 609CE6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:49:10 -0500 (EST)
Received: by mail-gg0-f182.google.com with SMTP id e27so235834gga.13
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:49:10 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id e4si1869913qas.153.2014.01.14.11.49.08
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 11:49:09 -0800 (PST)
Date: Tue, 14 Jan 2014 13:49:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 3/9] mm: page->pfmemalloc only used by slab/skb
In-Reply-To: <20140114180051.0181E467@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401141348130.19618@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180051.0181E467@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> page->pfmemalloc does not deserve a spot in 'struct page'.  It is
> only used transiently _just_ after a page leaves the buddy
> allocator.

Why would we need to do this if we are removing the cmpxchg_double?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
