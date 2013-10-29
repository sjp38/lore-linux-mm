Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9099E6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 16:49:43 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so573217pad.13
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 13:49:43 -0700 (PDT)
Received: from psmtp.com ([74.125.245.165])
        by mx.google.com with SMTP id gv2si15866262pbb.11.2013.10.29.13.49.40
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 13:49:41 -0700 (PDT)
Date: Tue, 29 Oct 2013 21:49:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131029204937.GG9568@quack.suse.cz>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <20131025214952.3eb41201@notabene.brown>
 <alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
 <154617470.12445.1382725583671.JavaMail.mail@webmail11>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154617470.12445.1382725583671.JavaMail.mail@webmail11>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: david@lang.hm, neilb@suse.de, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

On Fri 25-10-13 18:26:23, Artem S. Tashkinov wrote:
> Oct 25, 2013 05:26:45 PM, david wrote:
> On Fri, 25 Oct 2013, NeilBrown wrote:
> >
> >>
> >> What exactly is bothering you about this?  The amount of memory used or the
> >> time until data is flushed?
> >
> >actually, I think the problem is more the impact of the huge write later on.
> 
> Exactly. And not being able to use applications which show you IO
> performance like Midnight Commander. You might prefer to use "cp -a" but
> I cannot imagine my life without being able to see the progress of a
> copying operation. With the current dirty cache there's no way to
> understand how you storage media actually behaves.
  Large writes shouldn't stall your desktop, that's certain and we must fix
that. I don't find the problem with copy progress indicators that
pressing...

> Hopefully this issue won't dissolve into obscurity and someone will
> actually make up a plan (and a patch) how to make dirty write cache
> behave in a sane manner considering the fact that there are devices with
> very different write speeds and requirements. It'd be ever better, if I
> could specify dirty cache as a mount option (though sane defaults or
> semi-automatic values based on runtime estimates won't hurt).
> 
> Per device dirty cache seems like a nice idea, I, for one, would like to
> disable it altogether or make it an absolute minimum for things like USB
> flash drives - because I don't care about multithreaded performance or
> delayed allocation on such devices - I'm interested in my data reaching
> my USB stick ASAP - because it's how most people use them.
  See my other emails in this thread. There are ways to tune the amount of
dirty data allowed per device. Currently the result isn't very satisfactory
but we should have something usable after the next merge window.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
