Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D74776B00E7
	for <linux-mm@kvack.org>; Wed, 23 May 2012 11:17:05 -0400 (EDT)
Date: Wed, 23 May 2012 10:17:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <4FBCFBE0.2080803@parallels.com>
Message-ID: <alpine.DEB.2.00.1205231012330.30940@router.home>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com> <alpine.DEB.2.00.1205220855470.17600@router.home> <4FBBAE95.6080608@parallels.com> <alpine.DEB.2.00.1205221216050.17721@router.home>
 <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com> <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com> <4FBCD328.6060406@parallels.com> <1337775878.3013.16.camel@dabdike.int.hansenpartnership.com> <alpine.DEB.2.00.1205230947490.30940@router.home>
 <4FBCFBE0.2080803@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 23 May 2012, Glauber Costa wrote:

> So if I understand it correctly, this is mostly because the name string
> outlives the cache in the slub case, because of merging ?

Well this means we really only need the copying in slub which we already
have.

The problem is that you want to make this behavior uniform over all
allocators so that you do not have to allocate the string on your own.

Could you wait (and not rely on copying) until I am through with the
extraction project for common code for the allocators? At that point we
can resolve this issue consistently for all allocators.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
