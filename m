Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C0AA46B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 19:19:40 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so20848881pab.17
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 16:19:40 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id ad7si584373pbd.81.2014.09.04.16.19.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 16:19:39 -0700 (PDT)
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id B31D220825
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 19:19:35 -0400 (EDT)
Date: Thu, 4 Sep 2014 20:19:23 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140904231923.GA15320@khazad-dum.debian.net>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
 <20140904201123.GA9116@khazad-dum.debian.net>
 <5408C9C4.1010705@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5408C9C4.1010705@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

On Thu, 04 Sep 2014, H. Peter Anvin wrote:
> On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
> > I am worried of uncharted territory, here.  I'd actually advocate for not
> > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> > is using them as well.  Is this a real concern, or am I being overly
> > cautious?
> 
> It is extremely unlikely that we'd have PAT issues in 32-bit mode and
> not in 64-bit mode on the same CPU.

Sure, but is it really a good idea to enable this on the *old* non-64-bit
capable processors (note: I don't mean x86-64 processors operating in 32-bit
mode) ?

> As far as I know, the current blacklist rule is very conservative due to
> lack of testing more than anything else.

I was told that much in 2009 when I asked why cpuid 0x6d8 was blacklisted
from using PAT :-)

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
