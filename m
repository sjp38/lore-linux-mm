Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0D68E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:09:27 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d10-v6so4883121wrw.6
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 01:09:27 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n191-v6si13312795wmb.89.2018.09.19.01.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 19 Sep 2018 01:09:26 -0700 (PDT)
Date: Wed, 19 Sep 2018 10:09:24 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address
 (ptrval)/0xc00a0000
In-Reply-To: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: linux-mm@kvack.org, x86@kernel.org

Paul,

On Wed, 19 Sep 2018, Paul Menzel wrote:
> 
> With Linux 4.19-rc4+ and `CONFIG_DEBUG_WX=y`, I see the message below on
> the ASRock E350M1.
> 
> > [    1.813378] Freeing unused kernel image memory: 1112K
> > [    1.818662] Write protecting the kernel text: 8708k
> > [    1.818987] Write protecting the kernel read-only data: 2864k
> > [    1.818989] NX-protecting the kernel data: 5628k
> > [    1.819265] ------------[ cut here ]------------
> > [    1.819272] x86/mm: Found insecure W+X mapping at address
> > (ptrval)/0xc00a0000
> 
> I do not notice any problems with the system, but maybe something can be done
> to get rid of these.

Can you please enable CONFIG_X86_PTDUMP and provide the output of the files
in /sys/kernel/debug/page_tables/ ?

Thanks,

	tglx
