Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9256B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 06:00:00 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so4202245wgg.13
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 02:59:59 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id bf5si20133095wjc.82.2014.09.30.02.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 02:59:58 -0700 (PDT)
Date: Tue, 30 Sep 2014 10:59:46 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH resend] arm:extend the reserved memory for initrd to be
	page aligned
Message-ID: <20140930095946.GL5182@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net> <20140919095959.GA2295@e104818-lin.cambridge.arm.com> <20140925143142.GF5182@n2100.arm.linux.org.uk> <20140925154403.GL10390@e104818-lin.cambridge.arm.com> <35FD53F367049845BC99AC72306C23D103D6DB49163B@CNBJMBX05.corpusers.net> <15815.1412018518@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15815.1412018518@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Catalin Marinas' <catalin.marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, 'Uwe =?iso-8859-1?Q?Kleine-K=F6nig'?= <u.kleine-koenig@pengutronix.de>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

On Mon, Sep 29, 2014 at 03:21:58PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 26 Sep 2014 10:40:54 +0800, "Wang, Yalin" said:
> 
> > I am really confused,
> > I read this web:
> > http://www.arm.linux.org.uk/developer/patches/info.php
> > it said use diff -urN to generate patch like this:
> >
> > diff -Nru linux.orig/lib/string.c linux/lib/string.c
> >
> > but I see other developers use git format-patch to generate patch and
> > submit to the patch system.
> > Git format-patch format can also be accepted by the patch system correctly ?
> > If yes, I think this web should update,
> > Use git format-patch to generate patch is more convenient than use diff -urN
> 
> 'diff -urN' has the advantage that it will work against a tree extracted
> from a release tarball, and doesn't have a requirement that you have git
> installed.  Having said that, somebody who has access to the website probably
> should update it to mention that both methods are acceptable....

As the website includes *examples* of git formatted patches, no change
is necessary.

I've learned through writing those instructions that it is a bad idea to
_add_ additional words, because it gives people _more_ things to argue
about.  One form of words or examples is fine for one group of people,
but completely confuses another group of people.  You can't win.

That is one of the biggest reasons I hate writing user documentation.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
