Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E5EB76B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 04:59:59 -0400 (EDT)
Received: by widdi4 with SMTP id di4so13962398wid.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 01:59:59 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id dl8si3248634wib.11.2015.04.24.01.59.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 01:59:58 -0700 (PDT)
Message-ID: <553A05E9.7040601@nod.at>
Date: Fri, 24 Apr 2015 10:59:21 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 00/10] an introduction of library operating system
 for Linux (LibOS)
References: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>	<1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>	<5539F370.9070704@nod.at> <m2r3randg5.wl@sfc.wide.ad.jp>
In-Reply-To: <m2r3randg5.wl@sfc.wide.ad.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, upa@haeena.net, christoph.paasch@gmail.com, mathieu.lacage@gmail.com, libos-nuse@googlegroups.com

Hi!

Am 24.04.2015 um 10:22 schrieb Hajime Tazaki:
>> You *really* need to shape up wrt the build process.
> 
> at the moment, the implementation of libos can't automate to
> follow such changes in the build process. but good news is
> it's a trivial task to follow up the latest function.
> 
> my observation on this manual follow up since around 3.7
> kernel (2.5 yrs ago) is that these changes mostly happened
> during merge-window of each new version, and the fix only
> takes a couple of hours at maximum.
> 
> I think I can survive with these changes but I'd like to ask
> broader opinions.
> 
> 
> one more question:
> 
> I'd really like to have a suggestion on which tree I should
> base for libos tree.
> 
> I'm proposing a patchset to arnd/asm-generic tree (which I
> believe the base tree for new arch/), while the patchset is
> tested with davem/net-next tree because right now libos is
> only for net/.
> 
> shall I propose a patchset based on Linus' tree instead ?

I'd suggest the following:
Maintain LibOS in your git tree and follow Linus' tree.
Make sure that all kernel releases build and work.

This way you can experiment with automation and other
stuff. If it works well you can ask for mainline inclusion
after a few kernel releases.

Your git history will show how much maintenance burden
LibOS has and how much with every merge window breaks and
needs manual fixup.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
