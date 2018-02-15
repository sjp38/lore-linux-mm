Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 643B56B000C
	for <int-list-linux-mm@kvack.org>; Wed, 14 Feb 2018 22:44:54 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id x2so12215335plv.16
        for <int-list-linux-mm@kvack.org>; Wed, 14 Feb 2018 19:44:54 -0800 (PST)
Date: Wed, 14 Feb 2018 22:44:44 -0500
From: joe.korty@concurrent-rt.com
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180215034444.GA18849@zipoli.concurrent-rt.com>
Reply-To: "Joe Korty" <joe.korty@concurrent-rt.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
 <20180214104342.GA12209@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214104342.GA12209@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andy Lutomirski <luto@amacapital.net>, int-list-linux-mm@kvack.orglinux-mm@kvack.org

On Wed, Feb 14, 2018 at 11:43:42AM +0100, Pavel Machek wrote:
> We have just found out that majority of 64-bit machines are broken in
> rather fundamental ways (Spectre) and Intel does not even look
> interested in fixing that (because it would make them look bad on
> benchmarks).
> 
> Even when the Spectre bug is mitigated... this looks like can of worms
> that can not be closed.
> 
> OTOH -- we do know that there are non-broken machines out there,
> unfortunately they are mostly 32-bit :-). Removing support for
> majority of working machines may not be good idea...
> 
> [And I really hope future CPUs get at least option to treat cache miss
> as a side-effect -- thus disalowed during speculation -- and probably
> option to turn off speculation altogether. AFAICT, it should "only"
> result in 50% slowdown -- or that was result in some riscv
> presentation.]

Or, future CPU designs introduce shadow caches and shadow
TLBs which only speculation loads and sees and which
become real only if and whend the resultant speculative
calculations become real.

Joe
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
