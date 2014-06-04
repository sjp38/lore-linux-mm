Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4D96B0088
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 19:37:49 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so9349457wib.17
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 16:37:48 -0700 (PDT)
Received: from mail1.ugh.no (mail1.ugh.no. [2a01:7e00:e000:1f:be1f:6ced:ab0f:d5e3])
        by mx.google.com with ESMTPS id hl6si8072026wjb.55.2014.06.04.16.37.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jun 2014 16:37:47 -0700 (PDT)
Message-ID: <538FADC6.1080604@tomt.net>
Date: Thu, 05 Jun 2014 01:37:42 +0200
From: Andre Tomt <andre@tomt.net>
MIME-Version: 1.0
Subject: Re: Bad rss-counter is back on 3.14-stable
References: <20140604182739.GA30340@kroah.com>
In-Reply-To: <20140604182739.GA30340@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Brandon Philips <brandon.philips@coreos.com>

On 04. juni 2014 20:27, Greg KH wrote:
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

I saw a bunch of similar errors on 3.14.x up to and including 3.14.4,
running Java (Tomcat) and Postgres on Xen PV. Have not seen it since
"mm: use paravirt friendly ops for NUMA hinting ptes" landed in 3.14.5.

402e194dfc5b38d99f9c65b86e2666b29adebf8c in stable,
29c7787075c92ca8af353acd5301481e6f37082f upstream

As I did not follow the original discussion I have no idea if this is
the same thing, and I'm way too lazy to look for it now. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
