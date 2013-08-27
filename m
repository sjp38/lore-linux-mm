Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 5C2D56B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 12:32:37 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id w6so2749499lbh.5
        for <linux-mm@kvack.org>; Tue, 27 Aug 2013 09:32:35 -0700 (PDT)
Date: Tue, 27 Aug 2013 20:32:26 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130827163226.GU7416@moon>
References: <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
 <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
 <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
 <20130826222833.GA24320@redhat.com>
 <20130827083718.GC7416@moon>
 <20130827162427.GA26717@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130827162427.GA26717@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Aug 27, 2013 at 12:24:27PM -0400, Dave Jones wrote:
>  > 
>  > I managed to trigger the issue as well. The patch below fixes it.
>  > Dave, could you please give it a shot once time permit?
> 
> Seems to do the trick.
> 
> Tested-by: Dave Jones <davej@fedoraproject.org>

Thanks a lot, Dave!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
