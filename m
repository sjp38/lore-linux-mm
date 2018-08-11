Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8D346B0003
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 16:17:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r13-v6so3379375wmc.8
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 13:17:09 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m9-v6si9261508wru.90.2018.08.11.13.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Aug 2018 13:17:08 -0700 (PDT)
Date: Sat, 11 Aug 2018 22:16:56 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency
 detected
In-Reply-To: <CABXGCsNdt4=z0b2H0pf5-0HVeiDBcU3Q3c-+WZ-dsExxwih4YA@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1808112149280.1659@nanos.tec.linutronix.de>
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com> <20180811113039.GA10397@bombadil.infradead.org> <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de> <alpine.DEB.2.21.1808111552010.3202@nanos.tec.linutronix.de>
 <CABXGCsN2vUE-Lo32j6WeuqyQz620sdgkaSte=otV4dr5wcQwag@mail.gmail.com> <alpine.DEB.2.21.1808112015390.1659@nanos.tec.linutronix.de> <CABXGCsNdt4=z0b2H0pf5-0HVeiDBcU3Q3c-+WZ-dsExxwih4YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: willy@infradead.org, kvm@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, konrad.wilk@oracle.com, thomas.lendacky@amd.com

On Sun, 12 Aug 2018, Mikhail Gavrilov wrote:
> 
> Perfect, the issue was gone!
> Can I hope to see this patch in 4.18 kernel or already too late?

I fear it's late unless Paolo will pick it up, but it will be tagged for
stable anyway. I'll try to carve out a few minutes tomorrow to send a
proper patch with changelog, but now beer at the camp fire is more
important.

Thanks,

	tglx
