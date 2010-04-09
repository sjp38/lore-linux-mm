Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 85DDF6B0215
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:49:16 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o39GnAgL010079
	for <linux-mm@kvack.org>; Fri, 9 Apr 2010 09:49:11 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz29.hot.corp.google.com with ESMTP id o39Gn86D020354
	for <linux-mm@kvack.org>; Fri, 9 Apr 2010 09:49:09 -0700
Received: by pwj8 with SMTP id 8so1951370pwj.10
        for <linux-mm@kvack.org>; Fri, 09 Apr 2010 09:49:08 -0700 (PDT)
Date: Fri, 9 Apr 2010 09:49:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: fix caller tracking on !CONFIG_DEBUG_SLAB &&
 CONFIG_TRACING
In-Reply-To: <4BBEC92B.9060407@redhat.com>
Message-ID: <alpine.DEB.2.00.1004090947030.10992@chino.kir.corp.google.com>
References: <1270721493-27820-1-git-send-email-dfeng@redhat.com> <alpine.DEB.2.00.1004081209380.21040@chino.kir.corp.google.com> <4BBEC92B.9060407@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Monakhov <dmonakhov@openvz.org>, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Apr 2010, Xiaotian Feng wrote:

> > This doesn't work if the underlying slab allocator doesn't define
> > __kmalloc_node_track_caller() regardless of whether CONFIG_TRACING is
> > enabled or not.  SLOB, for example, never defines it, and that's why the
> > conditional exists in the way it currently does.
> > 
> 
> Sorry, I didn't realized this, can we use (defined(CONFIG_TRACING) &&
> defined(CONFIG_SLAB)) ?
> 

The valid configurations are

	(CONFIG_SLAB && (CONFIG_DEBUG_SLAB || CONFIG_TRACING)) || CONFIG_SLUB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
