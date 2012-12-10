Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id E01E56B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 16:54:38 -0500 (EST)
Date: Mon, 10 Dec 2012 22:54:36 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121210215436.GA31536@liondog.tnic>
References: <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
 <20121210110337.GH1009@suse.de>
 <20121210163904.GA22101@cmpxchg.org>
 <20121210180141.GK1009@suse.de>
 <50C62AE6.3030000@iskon.hr>
 <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com>
 <50C6477A.4090005@iskon.hr>
 <CA+55aFx9XSjtMZNuveyKrxL0LUjmZpFvJ7vzkjaKgQZLCs9QCg@mail.gmail.com>
 <20121210214256.GB23484@liondog.tnic>
 <CA+55aFzPa1tk_uWs_1cyYD0XpjWg_Fn+o431hUk3AnabOeUXSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+55aFzPa1tk_uWs_1cyYD0XpjWg_Fn+o431hUk3AnabOeUXSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Mon, Dec 10, 2012 at 01:47:23PM -0800, Linus Torvalds wrote:
> On Mon, Dec 10, 2012 at 1:42 PM, Borislav Petkov <bp@alien8.de> wrote:
> >
> > Aren't we gonna consider the out-of-tree vbox modules being loaded and
> > causing some corruptions like maybe the single-bit error above?
> >
> > I'm also thinking of this here: https://lkml.org/lkml/2011/10/6/317
> 
> Yup, that looks more likely, I agree.

@Zlatko: can your daughter try to retrigger the freeze without the vbox
modules loaded?

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
