Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03FE16B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 14:30:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z9-v6so1419037pfe.23
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 11:30:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 9-v6si1597652pgu.130.2018.07.03.11.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 11:30:50 -0700 (PDT)
Date: Tue, 3 Jul 2018 11:30:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Message-Id: <20180703113048.75989ea95833e9a2325687ec@linux-foundation.org>
In-Reply-To: <CAOesGMgGmr4o92subyJMGGbv7CxFYH_zKV01aWK4TwnEgzHTUQ@mail.gmail.com>
References: <201806301538.bewm1wka%fengguang.wu@intel.com>
	<CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
	<20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
	<20180630111210.ec9de2c2923a0c58b1357965@linux-foundation.org>
	<CAOesGMh6yVYKQ+dJbAsJWU=7wrfwW1cBwVbGoKNiG96_Mh6ebA@mail.gmail.com>
	<CAOesGMgGmr4o92subyJMGGbv7CxFYH_zKV01aWK4TwnEgzHTUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 3 Jul 2018 10:50:46 -0700 Olof Johansson <olof@lixom.net> wrote:

> > Solves it on my builder at least. Would be good to get this in.
> >
> > Acked-by: Olof Johansson <olof@lixom.net>
> 
> Since this doesn't seem to be in your queue at the moment, I've
> applied it to our set of fixes for 4.18 in arm-soc, I'll send to Linus
> at end of week and it'll be in -next as of now through there.

I queued it on June 30:

http://ozlabs.org/~akpm/mmots/broken-out/arm-disable-kcov-for-trusted-foundations-code.patch

but whatever.  If it turns up in -next I drop my copy.
