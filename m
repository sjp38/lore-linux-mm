Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC256B0036
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:47:12 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id jy17so19163578qeb.2
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:47:12 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id q6si73955935qag.136.2014.01.06.18.47.11
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:47:11 -0800 (PST)
Date: Mon, 6 Jan 2014 20:44:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slub: fix ALLOC_SLOWPATH stat
In-Reply-To: <20140106204300.DE79BA86@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401062044010.9444@nuc>
References: <20140106204300.DE79BA86@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Mon, 6 Jan 2014, Dave Hansen wrote:

> This patch moves stat(s, ALLOC_SLOWPATH) to be called from the
> same place that __slab_alloc() is.  This makes it much less
> likely that ALLOC_SLOWPATH will get botched again in the
> spaghetti-code inside __slab_alloc().


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
