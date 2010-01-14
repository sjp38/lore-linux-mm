Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B8F36B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:00:00 -0500 (EST)
Date: Thu, 14 Jan 2010 15:59:55 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <4B4F8D35.5050203@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1001141558260.20895@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com>
 <alpine.DEB.2.00.1001141457250.19915@router.home> <20100114212933.GK4545@ldl.fc.hp.com> <4B4F8D35.5050203@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alex Chiang <achiang@hp.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jan 2010, Pekka Enberg wrote:

> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=ff64d6c42abaffdb8686c77930eafb4da5b676f5

> Maybe your changes are trigger a latent bug with DEFINE_PER_CPU handling in
> SLUB?

There is no node -> cpu mapping like that in SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
