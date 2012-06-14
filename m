Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 915026B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:51:13 -0400 (EDT)
Date: Thu, 14 Jun 2012 10:19:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] make CFLGS_OFF_SLAB visible for all slabs
In-Reply-To: <1339676244-27967-5-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1206141019010.32075@router.home>
References: <1339676244-27967-1-git-send-email-glommer@parallels.com> <1339676244-27967-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> Since we're now moving towards a unified slab allocator interface,
> make CFLGS_OFF_SLAB visible to all allocators, even though SLAB keeps
> being its only users. Also, make the name consistent with the other
> flags, that start with SLAB_xx.

What is the significance of knowledge about internal slab structures (such
as the CFGLFS_OFF_SLAB) outside of the allocators?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
