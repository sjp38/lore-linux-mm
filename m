Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA05328
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 14:23:42 -0800 (PST)
Date: Wed, 26 Feb 2003 14:20:24 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] allow CONFIG_SWAP=n for i386
Message-Id: <20030226142024.614e2e0d.akpm@digeo.com>
In-Reply-To: <20030227002104.D15352@sgi.com>
References: <20030227002104.D15352@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@sgi.com> wrote:
>
> There's a bunch of minor fixes needed to disable the swap
> code for systems with mmu.

A worthy objective.

> +	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),

arch/um des not have __MUTEX_INITIALIZER, and I'm not sure that we want to
promote this to part of the kernel API, do we?

Might be better to leave that bit alone.  Maybe stick an initcall into
swap_state.c for it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
