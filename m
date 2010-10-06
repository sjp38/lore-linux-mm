Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A8B326B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:13:15 -0400 (EDT)
Date: Wed, 6 Oct 2010 07:03:43 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: OOM panics with zram
Message-ID: <20101006140343.GC19470@kroah.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
 <1284053081.7586.7910.camel@nimitz>
 <4CA8CE45.9040207@vflare.org>
 <20101005234300.GA14396@kroah.com>
 <4CABDF0E.3050400@vflare.org>
 <20101006023624.GA27685@kroah.com>
 <4CABFB6F.2070800@vflare.org>
 <AANLkTi=0bPudtyVzebvM0hZUB6DdDhjopB06FOww8hvt@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=0bPudtyVzebvM0hZUB6DdDhjopB06FOww8hvt@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 10:38:59AM +0300, Pekka Enberg wrote:
> Hi,
> 
> On Wed, Oct 6, 2010 at 7:30 AM, Nitin Gupta <ngupta@vflare.org> wrote:
> > Deleting it from staging would not help much. Much more helpful would
> > be to sync at least the mainline and linux-next version of the driver
> > so it's easier to develop against these kernel trees.  Initially, I
> > thought -staging means that any reviewed change can quickly make it
> > to *both* linux-next and more importantly -staging in mainline. Working/
> > Testing against mainline is much smoother than against linux-next.
> 
> We can't push the patches immediately to mainline because we need to
> respect the merge window. You shouldn't need to rely on linux-next for
> testing, though, but work directly against Greg's staging tree. Greg,
> where's the official tree at, btw? The tree at
> 
>   http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/
> 
> seems empty.

Oops, I need to update the MAINTAINERS file, the proper place for the
staging tree is now in git, at

git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-next-2.6.git

which feeds directly into the linux-next tree.

hope this helps,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
