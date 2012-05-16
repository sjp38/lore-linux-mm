Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 4CE786B00E7
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:28:44 -0400 (EDT)
Date: Wed, 16 May 2012 09:28:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 0/9] Sl[auo]b: Common functionality
 V1
In-Reply-To: <4FB36079.9030606@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160928120.25603@router.home>
References: <20120514201544.334122849@linux.com> <4FB36079.9030606@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> > In the far future one could envision that the current allocators will
> > just become storage algorithms that can be chosen based on the need of
> > the subsystem. F.e.
> >
> > Cpu cache dependend performance		= Bonwick allocator (SLAB)
> > Minimal cycle count and cache footprint	= SLUB
> > Maximum storage density			= SLOB
>
> While we are at it, do we plan to lift the vowel-only usage restriction and
> start allowing consonants for the 3rd letter? We're running short of vowels,
> so we can only accommodate 2 more allocators if this restriction stays.

Well if we go to storage algorithms then we can have free naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
