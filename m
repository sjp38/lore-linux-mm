Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBD16B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 04:54:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l23-v6so232272edr.1
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 01:54:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15-v6si722111eds.268.2018.06.26.01.54.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 01:54:50 -0700 (PDT)
Date: Tue, 26 Jun 2018 10:54:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
Message-ID: <20180626085449.GU28965@dhcp22.suse.cz>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
 <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de>
 <1529938470.14039.134.camel@hpe.com>
 <20180625175225.GQ28965@dhcp22.suse.cz>
 <1529961187.14039.206.camel@hpe.com>
 <20180626063521.GT28965@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806261043080.2204@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806261043080.2204@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>

On Tue 26-06-18 10:45:11, Thomas Gleixner wrote:
> On Tue, 26 Jun 2018, Michal Hocko wrote:
> > On Mon 25-06-18 21:15:03, Kani Toshimitsu wrote:
> > > Lastly, for the code maintenance, I believe this memory allocation keeps
> > > the code much simpler than it would otherwise need to manage a special
> > > page list.
> > 
> > Yes, I can see a simplicity as a reasonable argument for a quick fix,
> > which these pile is supposed to be AFAIU. So this might be good to go
> > from that perspective, but I believe that this should be changed in
> > future at least.
> 
> So the conclusion is, that we ship this set of patches now to cure the
> existing wreckage, right?

Joerg was suggesting some alternative but I got lost in the discussion
to be honest so I might mis{interpret,remember}.

> Fine with that, but who will take care of reworking it proper? I'm
> concerned that this will just go stale the moment the fixes hit the tree.

Yeah, this is why I usually try to push back hard because "will be fixed
later" is similar to say "documentation will come later" etc...

A big fat TODO would be appropriate so it won't get forgotten at least.
-- 
Michal Hocko
SUSE Labs
