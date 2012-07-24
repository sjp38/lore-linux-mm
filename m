Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 8EB9D6B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 09:27:46 -0400 (EDT)
Date: Tue, 24 Jul 2012 14:27:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
Message-ID: <20120724132741.GS9222@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <1343109531.7412.47.camel@marge.simpson.net>
 <CAJd=RBC835W52nsXCqhM_4KR3CuLF9zijh3416LiJLybTuR_YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBC835W52nsXCqhM_4KR3CuLF9zijh3416LiJLybTuR_YA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>, Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2012 at 09:18:16PM +0800, Hillf Danton wrote:
> On Tue, Jul 24, 2012 at 1:58 PM, Mike Galbraith <efault@gmx.de> wrote:
> > FWIW, I'm all for performance backports.  They do have a downside though
> > (other than the risk of bugs slipping in, or triggering latent bugs).
> >
> > When the next enterprise kernel is built, marketeers ask for numbers to
> > make potential customers drool over, and you _can't produce any_ because
> > you wedged all the spiffy performance stuff into the crusty old kernel.
> >
> Well do your job please.
> 

I would suggest the user in question use the normal support channels for
resolving a potentially SLES-specific bug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
