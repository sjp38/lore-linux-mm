Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA07564
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 15:08:16 -0800 (PST)
Date: Wed, 26 Feb 2003 15:04:57 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] allow CONFIG_SWAP=n for i386
Message-Id: <20030226150457.528bb284.akpm@digeo.com>
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

> +	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),

The ampersand needs to be removed.

Please at least compile-test stuff.  Actually checking that it runs appears
to be optional lately anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
