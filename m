Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97F5328025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:37:19 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id h201so200246580qke.7
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:37:19 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id 23si3992288qkd.84.2016.11.10.09.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Nov 2016 09:37:15 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 4edd4bf5
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 17:35:07 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 6219ec76 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Thu, 10 Nov 2016 17:35:06 +0000 (UTC)
Received: by mail-lf0-f49.google.com with SMTP id b14so195384767lfg.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:37:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <db056fb5-82b3-c17e-46ce-263872ef7334@imgtec.com>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
 <alpine.DEB.2.20.1611092227200.3501@nanos> <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
 <alpine.DEB.2.20.1611100959040.3501@nanos> <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
 <db056fb5-82b3-c17e-46ce-263872ef7334@imgtec.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 10 Nov 2016 18:37:10 +0100
Message-ID: <CAHmME9ooeH2Qdu3zVS-_i_9_3AR0bDrEe_8+D3FS7E7NvMLG-Q@mail.gmail.com>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Redfearn <matt.redfearn@imgtec.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

Hi Matt,

On Thu, Nov 10, 2016 at 5:36 PM, Matt Redfearn <matt.redfearn@imgtec.com> wrote:
>
> I don't see a reason not to do this - I'm taking a look into it.

Great thanks! This is good to hear. If you go into the arch/ directory
and simply grep for "irq_stack", you can pretty easily base your
implementation on a variety of other architectures' implementations.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
