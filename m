Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 92BE16B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 02:35:15 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5570024iaj.14
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 23:35:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9AFD28.2030801@hp.com>
References: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com>
	<alpine.DEB.2.00.1204270911080.29198@router.home>
	<4F9AFD28.2030801@hp.com>
Date: Mon, 30 Apr 2012 09:35:14 +0300
Message-ID: <CAOJsxLGXZsq22LuNa5ef5iv7Jy0A0w_S2MbDQeBW=dFvUwFRjA@mail.gmail.com>
Subject: Re: [PATCH] slub: prevent validate_slab() error due to race condition
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Christoph Lameter <cl@linux.com>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Morris, Donald George (HP-UX Cupertino)" <don.morris@hp.com>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Apr 27, 2012 at 11:10 PM, Waiman Long <waiman.long@hp.com> wrote:
> Thank for the quick response. I have no problem for moving the node-lock
> taking into free_debug_processing. Of the 2 problems that are reported, this
> is a more serious one and so need to be fixed sooner rather than later. For
> the other one, we can take more time to find a better solution.
>
> So are you going to integrate your change to the mainline?

Christoph, can you send the patch with an improved changelog that also
explains what the problem is?

How far back in the stable series do we want to backport this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
