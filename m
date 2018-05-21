Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A766E6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:37:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r63-v6so9585088pfl.12
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:37:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16-v6sor2135847pge.189.2018.05.21.11.37.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 11:37:44 -0700 (PDT)
Date: Mon, 21 May 2018 11:37:42 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180521183742.GC14774@vader>
References: <20180518090636.GA14738@kmo-pixel>
 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
 <20180520221733.GA11495@kmo-pixel>
 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
 <20180520223116.GB11495@kmo-pixel>
 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
 <20180520232139.GE11495@kmo-pixel>
 <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
 <20180520235853.GF11495@kmo-pixel>
 <d3fbfaa667f5ac64c1f230249e3333594cb4a128.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3fbfaa667f5ac64c1f230249e3333594cb4a128.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Mon, May 21, 2018 at 03:11:08PM +0000, Bart Van Assche wrote:
> On Sun, 2018-05-20 at 19:58 -0400, Kent Overstreet wrote:
> > On Sun, May 20, 2018 at 11:40:45PM +0000, Bart Van Assche wrote:
> > > On Sun, 2018-05-20 at 19:21 -0400, Kent Overstreet wrote:
> > > > I really have better things to do than debug someone else's tests...
> > > > [ ... ]
> > > > ../run_tests: line 65: cd: /lib/modules/4.16.0+/kernel/block: No such file or directory
> > > 
> > > Kernel v4.16 is too old to run these tests. The srp-test script needs the
> > > following commit that went upstream in kernel v4.17-rc1:
> > > 
> > > 63cf1a902c9d ("IB/srpt: Add RDMA/CM support")
> > 
> > Same output on Jens' for-next branch.
> 
> Others have been able to run the srp-test software with the instructions
> provided earlier in this e-mail thread. Can you share the kernel messages from
> around the time the test was run (dmesg, /var/log/messages or /var/log/syslog)?
> 
> Thanks,
> 
> Bart.

Bart,

Have you made any progress in porting srp-test to blktests so we don't
have to have this conversation again?
