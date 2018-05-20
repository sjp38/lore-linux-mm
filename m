Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B271E6B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 18:31:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m22-v6so1404285qkk.22
        for <linux-mm@kvack.org>; Sun, 20 May 2018 15:31:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k56-v6sor8913036qta.138.2018.05.20.15.31.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 15:31:19 -0700 (PDT)
Date: Sun, 20 May 2018 18:31:16 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180520223116.GB11495@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
 <20180518090636.GA14738@kmo-pixel>
 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
 <20180520221733.GA11495@kmo-pixel>
 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Sun, May 20, 2018 at 10:19:13PM +0000, Bart Van Assche wrote:
> On Sun, 2018-05-20 at 18:17 -0400, Kent Overstreet wrote:
> > On Fri, May 18, 2018 at 03:12:27PM +0000, Bart Van Assche wrote:
> > > On Fri, 2018-05-18 at 05:06 -0400, Kent Overstreet wrote:
> > > > On Thu, May 17, 2018 at 08:54:57PM +0000, Bart Van Assche wrote:
> > > > > With Jens' latest for-next branch I hit the kernel warning shown below. Can
> > > > > you have a look?
> > > > 
> > > > Any hints on how to reproduce it?
> > > 
> > > Sure. This is how I triggered it:
> > > * Clone https://github.com/bvanassche/srp-test.
> > > * Follow the instructions in README.md.
> > > * Run srp-test/run_tests -c -r 10
> > 
> > Can you bisect it? I don't have infiniband hardware handy...
> 
> Hello Kent,
> 
> Have you noticed that the test I described uses the rdma_rxe driver and hence that
> no InfiniBand hardware is needed to run that test?

No, I'm not terribly familiar with infiniband stuff....

Do you have some sort of self contained test/qemu recipe? I would really rather
not have to figure out how to configure multipath, and infiniband, and I'm not
even sure what else is needed based on that readme...
