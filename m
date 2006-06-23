In-reply-to: <Pine.LNX.4.64.0606231042350.6483@g5.osdl.org> (message from
	Linus Torvalds on Fri, 23 Jun 2006 10:49:15 -0700 (PDT))
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175253.24655.96323.sendpatchset@lappy>
 <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>
 <1151019590.15744.144.camel@lappy> <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>
 <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com> <Pine.LNX.4.64.0606231042350.6483@g5.osdl.org>
Message-Id: <E1Ftq54-0002Og-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 23 Jun 2006 20:08:34 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: hugh@veritas.com, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org, dhowells@redhat.com, christoph@lameter.com, mbligh@google.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> Well, I've got two reasons to want to fast-track it:
> 
>  - it's exactly what I wanted to see, so I'm obviously personally happy 
>    with the patch

Heh, IIRC you rejected the idea of doing a fault on dirtying for
performance reasons, during the discussion of VM deadlocks in FUSE.

Anyway, I'm more than happy, since David and Peter basically solved
the problem, so shared writable mappings should now be possible to do.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
