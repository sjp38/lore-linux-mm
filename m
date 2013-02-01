Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D34B36B000A
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 21:11:59 -0500 (EST)
Date: Thu, 31 Jan 2013 21:11:50 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] staging: zsmalloc: remove unused pool name
Message-ID: <20130201021149.GB3416@konrad-lan.dumpdata.com>
References: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <51093F43.2090503@linux.vnet.ibm.com>
 <20130130172159.GA24760@kroah.com>
 <20130130172956.GC2217@konrad-lan.dumpdata.com>
 <20130131053235.GD3228@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130131053235.GD3228@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, torvalds@linux-foundation.org
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> > > {sigh} you just made me have to edit your patch by hand, you now owe me
> > > a beer...
> > > 
> > Should we codify that :-)
> > 
> > 
> > diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
> > index c379a2a..f879c60 100644
> > --- a/Documentation/SubmittingPatches
> > +++ b/Documentation/SubmittingPatches
> > @@ -94,6 +94,7 @@ includes updates for subsystem X.  Please apply."
> >  The maintainer will thank you if you write your patch description in a
> >  form which can be easily pulled into Linux's source code management
> >  system, git, as a "commit log".  See #15, below.
> > +If the maintainer has to hand-edit your patch, you owe them a beer.
> >  
> >  If your description starts to get long, that's a sign that you probably
> >  need to split up your patch.  See #3, next.
> 
> Yes we do need to codify this, but let's be fair, not everyone likes
> beer:
> 
> diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
> index c379a2a..d1bec01 100644
> --- a/Documentation/SubmittingPatches
> +++ b/Documentation/SubmittingPatches
> @@ -93,7 +93,9 @@ includes updates for subsystem X.  Please apply."
>  
>  The maintainer will thank you if you write your patch description in a
>  form which can be easily pulled into Linux's source code management
> -system, git, as a "commit log".  See #15, below.
> +system, git, as a "commit log".  See #15, below.  If the maintainer has
> +to hand-edit your patch, you owe them the beverage of their choice the
> +next time you see them.
>  
>  If your description starts to get long, that's a sign that you probably
>  need to split up your patch.  See #3, next.

Does that mean you owe Linus a whiskey bottle since you didn't properly
sign this patch :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
