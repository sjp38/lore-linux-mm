Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 767A16B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 04:45:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g73-v6so464997wmc.5
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 01:45:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 190-v6si1322746wmr.134.2018.06.26.01.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 01:45:20 -0700 (PDT)
Date: Tue, 26 Jun 2018 10:45:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
In-Reply-To: <20180626063521.GT28965@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1806261043080.2204@nanos.tec.linutronix.de>
References: <20180516233207.1580-1-toshi.kani@hpe.com> <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de> <1529938470.14039.134.camel@hpe.com> <20180625175225.GQ28965@dhcp22.suse.cz> <1529961187.14039.206.camel@hpe.com>
 <20180626063521.GT28965@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>

On Tue, 26 Jun 2018, Michal Hocko wrote:
> On Mon 25-06-18 21:15:03, Kani Toshimitsu wrote:
> > Lastly, for the code maintenance, I believe this memory allocation keeps
> > the code much simpler than it would otherwise need to manage a special
> > page list.
> 
> Yes, I can see a simplicity as a reasonable argument for a quick fix,
> which these pile is supposed to be AFAIU. So this might be good to go
> from that perspective, but I believe that this should be changed in
> future at least.

So the conclusion is, that we ship this set of patches now to cure the
existing wreckage, right?

Fine with that, but who will take care of reworking it proper? I'm
concerned that this will just go stale the moment the fixes hit the tree.

Thanks,

	tglx
