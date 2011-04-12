Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5E184900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 14:02:23 -0400 (EDT)
Date: Tue, 12 Apr 2011 13:02:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix a typo in config name
In-Reply-To: <4DA3FDB2.9090100@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104121301430.14692@router.home>
References: <4DA3FDB2.9090100@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, penberg@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 12 Apr 2011, Li Zefan wrote:

> There's no config named SLAB_DEBUG, and it should be a typo
> of SLUB_DEBUG.
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>
> not slub expert, don't know how this bug affects slub debugging.

Affects the bootstrap code.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
