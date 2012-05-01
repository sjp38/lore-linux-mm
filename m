Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D69CF6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 16:23:46 -0400 (EDT)
Date: Tue, 1 May 2012 15:23:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: prevent validate_slab() error due to race
 condition
In-Reply-To: <CAOJsxLGXZsq22LuNa5ef5iv7Jy0A0w_S2MbDQeBW=dFvUwFRjA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205011522340.2091@router.home>
References: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com> <alpine.DEB.2.00.1204270911080.29198@router.home> <4F9AFD28.2030801@hp.com> <CAOJsxLGXZsq22LuNa5ef5iv7Jy0A0w_S2MbDQeBW=dFvUwFRjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Waiman Long <waiman.long@hp.com>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Morris, Donald George (HP-UX Cupertino)" <don.morris@hp.com>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, 30 Apr 2012, Pekka Enberg wrote:

> On Fri, Apr 27, 2012 at 11:10 PM, Waiman Long <waiman.long@hp.com> wrote:
> > Thank for the quick response. I have no problem for moving the node-lock
> > taking into free_debug_processing. Of the 2 problems that are reported, this
> > is a more serious one and so need to be fixed sooner rather than later. For
> > the other one, we can take more time to find a better solution.
> >
> > So are you going to integrate your change to the mainline?
>
> Christoph, can you send the patch with an improved changelog that also
> explains what the problem is?


Will do so once I get back from the conference I am at.

> How far back in the stable series do we want to backport this?

This only affects slab validation when running with deubgging so I would
suggest to merge in the next cycle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
