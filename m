Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A263C6B009C
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 20:18:01 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so244731pbc.24
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 17:18:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tq1si9142911pbc.162.2014.06.04.17.17.59
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 17:18:00 -0700 (PDT)
Date: Wed, 4 Jun 2014 17:21:40 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Bad rss-counter is back on 3.14-stable
Message-ID: <20140605002140.GA24037@kroah.com>
References: <20140604182739.GA30340@kroah.com>
 <538FADC6.1080604@tomt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <538FADC6.1080604@tomt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andre Tomt <andre@tomt.net>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Brandon Philips <brandon.philips@coreos.com>

On Thu, Jun 05, 2014 at 01:37:42AM +0200, Andre Tomt wrote:
> On 04. juni 2014 20:27, Greg KH wrote:
> > Hi all,
> > 
> > Dave, I saw you mention that you were seeing the "Bad rss-counter" line
> > on 3.15-rc1, but I couldn't find any follow-up on this to see if anyone
> > figured it out, or did it just "magically" go away?
> > 
> > I ask as Brandon is seeing this same message a lot on a 3.14.4 kernel,
> > causing system crashes and problems:
> > 
> > [16591492.449718] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:0 val:-1836508
> > [16591492.449737] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:1 val:1836508
> > 
> > [20783350.461716] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:0 val:-52518
> > [20783350.461734] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:1 val:52518
> > 
> > [21393387.112302] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:0 val:-1767569
> > [21393387.112321] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:1 val:1767569
> > 
> > [21430098.512837] BUG: Bad rss-counter state mm:ffff880100036680 idx:0 val:-2946
> > [21430098.512854] BUG: Bad rss-counter state mm:ffff880100036680 idx:1 val:2946
> > 
> > Anyone have any ideas of a 3.15-rc patch I should be including in
> > 3.14-stable to resolve this?
> 
> I saw a bunch of similar errors on 3.14.x up to and including 3.14.4,
> running Java (Tomcat) and Postgres on Xen PV. Have not seen it since
> "mm: use paravirt friendly ops for NUMA hinting ptes" landed in 3.14.5.
> 
> 402e194dfc5b38d99f9c65b86e2666b29adebf8c in stable,
> 29c7787075c92ca8af353acd5301481e6f37082f upstream
> 
> As I did not follow the original discussion I have no idea if this is
> the same thing, and I'm way too lazy to look for it now. ;-)

Ah, nice find.

Brandon, I think 3.14.5 is in the CoreOs tree, can you update to that on
these boxes to see if it solves the issue?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
