Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 07F696B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:18:31 -0400 (EDT)
Date: Tue, 22 May 2012 12:18:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab+slob: dup name string
In-Reply-To: <4FBBB059.1060903@parallels.com>
Message-ID: <alpine.DEB.2.00.1205221216590.17721@router.home>
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home> <4FBBB059.1060903@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On Tue, 22 May 2012, Glauber Costa wrote:

> On 05/22/2012 05:58 PM, Christoph Lameter wrote:
> > On Tue, 22 May 2012, Glauber Costa wrote:
> >
> > > [ v2: Also dup string for early caches, requested by David Rientjes ]
> >
> > kstrdups that early could cause additional issues. Its better to leave
> > things as they were.
> >
>
> For me is really all the same. But note that before those kstrdups, we do a
> bunch of kmallocs as well already. (ex:

We check carefully and make sure those caches are present before doing
these kmallocs. See the slab bootup code. A kstrdup may take a variously
sized string and explode because the required kmalloc cache is not
present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
