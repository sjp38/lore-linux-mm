Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4726B005A
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 15:12:42 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so8930623wes.37
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:12:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si36833053wiy.24.2014.06.04.12.12.40
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 12:12:41 -0700 (PDT)
Date: Wed, 4 Jun 2014 15:12:28 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: Bad rss-counter is back on 3.14-stable
Message-ID: <20140604191228.GB12375@redhat.com>
References: <20140604182739.GA30340@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140604182739.GA30340@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Brandon Philips <brandon.philips@coreos.com>

On Wed, Jun 04, 2014 at 11:27:39AM -0700, Greg KH wrote:
 > Hi all,
 > 
 > Dave, I saw you mention that you were seeing the "Bad rss-counter" line
 > on 3.15-rc1, but I couldn't find any follow-up on this to see if anyone
 > figured it out, or did it just "magically" go away?
 > 
 > I ask as Brandon is seeing this same message a lot on a 3.14.4 kernel,
 > causing system crashes and problems:
 > 
 > [16591492.449718] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:0 val:-1836508
 > [16591492.449737] BUG: Bad rss-counter state mm:ffff8801ced99880 idx:1 val:1836508
 > 
 > [20783350.461716] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:0 val:-52518
 > [20783350.461734] BUG: Bad rss-counter state mm:ffff8801d2b1dc00 idx:1 val:52518
 > 
 > [21393387.112302] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:0 val:-1767569
 > [21393387.112321] BUG: Bad rss-counter state mm:ffff8801d0104e00 idx:1 val:1767569
 > 
 > [21430098.512837] BUG: Bad rss-counter state mm:ffff880100036680 idx:0 val:-2946
 > [21430098.512854] BUG: Bad rss-counter state mm:ffff880100036680 idx:1 val:2946
 > 
 > Anyone have any ideas of a 3.15-rc patch I should be including in
 > 3.14-stable to resolve this?

hard to tell if they were the same issues I was seeing without the full
backtrace. The only bad rss bugs that I recall being fixed for sure were
the ones that Hugh nailed down right before 3.14 (887843961c4b)

I've not seen anything in a while, but that may just be because I end up
hitting other bugs before they get a chance to show.

Brandon, what kind of workload is that machine doing ? I wonder if I can
add something to trinity to make it provoke it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
