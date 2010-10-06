Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 325DA6B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 03:39:01 -0400 (EDT)
Received: by iwn41 with SMTP id 41so2105318iwn.14
        for <linux-mm@kvack.org>; Wed, 06 Oct 2010 00:38:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CABFB6F.2070800@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1284053081.7586.7910.camel@nimitz>
	<4CA8CE45.9040207@vflare.org>
	<20101005234300.GA14396@kroah.com>
	<4CABDF0E.3050400@vflare.org>
	<20101006023624.GA27685@kroah.com>
	<4CABFB6F.2070800@vflare.org>
Date: Wed, 6 Oct 2010 10:38:59 +0300
Message-ID: <AANLkTi=0bPudtyVzebvM0hZUB6DdDhjopB06FOww8hvt@mail.gmail.com>
Subject: Re: OOM panics with zram
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Oct 6, 2010 at 7:30 AM, Nitin Gupta <ngupta@vflare.org> wrote:
> Deleting it from staging would not help much. Much more helpful would
> be to sync at least the mainline and linux-next version of the driver
> so it's easier to develop against these kernel trees. =A0Initially, I
> thought -staging means that any reviewed change can quickly make it
> to *both* linux-next and more importantly -staging in mainline. Working/
> Testing against mainline is much smoother than against linux-next.

We can't push the patches immediately to mainline because we need to
respect the merge window. You shouldn't need to rely on linux-next for
testing, though, but work directly against Greg's staging tree. Greg,
where's the official tree at, btw? The tree at

  http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/

seems empty.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
