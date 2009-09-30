Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6B6856B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 07:53:43 -0400 (EDT)
Date: Wed, 30 Sep 2009 14:02:03 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-ID: <20090930120202.GB1412@ucw.cz>
References: <4AB9A0D6.1090004@crca.org.au> <Pine.LNX.4.64.0909232056020.3360@sister.anvils> <4ABC7FBC.4050409@crca.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ABC7FBC.4050409@crca.org.au>
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > Does TuxOnIce rely on CONFIG_MMU?  If so, then the TuxOnIce patch
> > could presumably reuse VM_MAPPED_COPY for now - but don't be
> > surprised if that's one we clean away later on.
> 
> Hmm. I'm not sure. The requirements are the same as for swsusp and
> uswsusp. Is there some tool to graph config dependencies?

I don't think swsusp was ported on any -nommu architecture, so config
dependency on MMU should be ok. OTOH such port should be doable...

								Pavel 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
