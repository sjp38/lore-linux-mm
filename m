Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F02536B004D
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 23:46:53 -0400 (EDT)
Message-ID: <4A67DD16.1090704@cs.columbia.edu>
Date: Wed, 22 Jul 2009 23:46:30 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v17][PATCH 52/60] c/r: support semaphore sysv-ipc
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-53-git-send-email-orenl@librato.com> <20090722172502.GA15805@lenovo>
In-Reply-To: <20090722172502.GA15805@lenovo>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Oren Laadan <orenl@librato.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>



Cyrill Gorcunov wrote:
> [Oren Laadan - Wed, Jul 22, 2009 at 06:00:14AM -0400]
> ...
> | +static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
> | +{
> | +	struct sem *sma;
> | +	int i, ret;
> | +
> | +	sma = kmalloc(nsems * sizeof(*sma), GFP_KERNEL);
> 
> Forgot to
> 
> 	if (!sma)
> 		return -ENOMEM;
> 
> right?

Yep !  thanks...  (fixed commit to branch ckpt-v17-dev)

Oren.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
