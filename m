Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDE06B0260
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:40:00 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id q128so194280184qkd.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:40:00 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id i46si4006500qta.29.2016.11.10.09.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Nov 2016 09:39:58 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 925f3ce3
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 17:37:50 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 950b5a68 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 17:37:49 +0000 (UTC)
Received: by mail-lf0-f50.google.com with SMTP id b14so195443432lfg.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:39:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611101351260.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <alpine.DEB.2.20.1611092227200.3501@nanos> <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
 <alpine.DEB.2.20.1611100959040.3501@nanos> <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
 <alpine.DEB.2.20.1611101351260.3501@nanos>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 10 Nov 2016 18:39:54 +0100
Message-ID: <CAHmME9rv8CfgY87S_HVN3njc2RnisjoxzfZxY=H=2FzZkrQqLg@mail.gmail.com>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

Hi Thomas,

On Thu, Nov 10, 2016 at 2:00 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> Do not even think about going there. That's going to be a major
> mess.

Lol! Okay. Thank you for reigning in my clearly reckless
propensities... Sometimes playing in traffic is awfully tempting.

>
> As a short time workaround you can increase THREAD_SIZE_ORDER for now and
> then fix it proper with switching to seperate irq stacks.

Okay. I think in the end I'll kmalloc, accept the 16% slowdown [1],
and focus efforts on having a separate IRQ stack. Matt emailed in this
thread saying he was already looking into it, so I think by the time
that slowdown makes a difference, we'll have the right pieces in place
anyway.

Thanks for the guidance here.

Regards,
Jason

[1] https://git.zx2c4.com/WireGuard/commit/?id=cc3d7df096a88cdf96d016bdcb2f78fa03abb6f3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
