Return-Path: <linux-kernel-owner+w=401wt.eu-S1754053AbYLMAaO@vger.kernel.org>
Date: Sat, 13 Dec 2008 01:29:35 +0100
From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
Message-ID: <20081213002934.GB3084@local>
References: <43FC624C55D8C746A914570B66D642610367F29B@cos-us-mb03.cos.agilent.com> <1228379942.5092.14.camel@twins> <20081204180809.GB3079@local> <1228461060.18899.8.camel@twins> <20081205094447.GA3081@local> <208aa0f00812051632h38fc0a5g58d233190436cc90@mail.gmail.com> <1229102712.13566.14.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1229102712.13566.14.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Edward Estabrook <edward.estabrook.lkml@gmail.com>, "Hans J. Koch" <hjk@linutronix.de>, edward_estabrook@agilent.com, linux-kernel@vger.kernel.org, gregkh@suse.de, edward.estabrook@gmail.com, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 12, 2008 at 06:25:12PM +0100, Peter Zijlstra wrote:
> On Fri, 2008-12-05 at 16:32 -0800, Edward Estabrook wrote:
> > > Well, UIO already rapes the mmap interface by using the "offset" parameter to
> > > pass in the number of the mapping.
> > 
> > Exactly.
> 
> Had I known about it then, I'd NAK'd it, but I guess now that its
> already merged changing it will be hard :/

It was in -mm for half a year before it went to mainline in 2.6.23, the
documentation being present all the time. It was discussed intensively
on lkml, and several core kernel developers reviewed it. The special use
of the mmap() offset parameter was never even mentioned by anybody. I
remember that so well because I actually expected critizism, but everybody
was fine with it. And to be honest, even though it's unusual, I still find
it a good solution.

Thanks,
Hans
