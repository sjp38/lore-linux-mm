Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A43806B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 20:47:51 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d67so176210109qkc.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 17:47:51 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id y80si1680684qky.109.2016.11.09.17.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Nov 2016 17:47:50 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 2364fbcf
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 01:45:47 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id d58c8976 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 01:45:47 +0000 (UTC)
Received: by mail-lf0-f49.google.com with SMTP id c13so178148495lfg.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 17:47:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5823BCA3.2020202@caviumnetworks.com>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <5823BCA3.2020202@caviumnetworks.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 10 Nov 2016 02:47:47 +0100
Message-ID: <CAHmME9oXsRrABzCjCQ_+O+QJmMgWyoyj73igHLaJKNfbf-brDQ@mail.gmail.com>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Daney <ddaney@caviumnetworks.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On Thu, Nov 10, 2016 at 1:17 AM, David Daney <ddaney@caviumnetworks.com> wrote:
> Easiest thing to do would be to select 16K page size in your .config, I
> think that will give you a similar sized stack.

I didn't realize that was possible...

I'm mostly concerned about the best way to deal with systems that have
a limited stack size on architectures without support for separate irq
stacks. Part of this I assume involves actually detecting with a
processor definition that the current architecture has a deceptively
small stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
