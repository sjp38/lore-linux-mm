Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2C8866B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:57:32 -0400 (EDT)
Date: Thu, 2 Aug 2012 08:57:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [9/9] Do slab aliasing call from common code
In-Reply-To: <501A2B34.9070804@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020857011.23049@router.home>
References: <20120731173620.432853182@linux.com> <20120731173638.649541860@linux.com> <501A2B34.9070804@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> This one didn't apply for me. I used pekka's tree + your other 8 patches
> (being careful about the 8th one). Maybe you need to refresh this as
> well as your 8th patch ?
>
> I could go see where it conflicts, but I'd like to make sure I am
> reviewing/testing the code exactly as you intended it to be.

Yea well it may be better to use yesterdays patchset instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
