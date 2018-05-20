Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF346B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 19:58:58 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t24-v6so12690770qtn.7
        for <linux-mm@kvack.org>; Sun, 20 May 2018 16:58:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t34-v6sor9252002qth.85.2018.05.20.16.58.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 16:58:57 -0700 (PDT)
Date: Sun, 20 May 2018 19:58:53 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180520235853.GF11495@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
 <20180518090636.GA14738@kmo-pixel>
 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
 <20180520221733.GA11495@kmo-pixel>
 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
 <20180520223116.GB11495@kmo-pixel>
 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
 <20180520232139.GE11495@kmo-pixel>
 <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Sun, May 20, 2018 at 11:40:45PM +0000, Bart Van Assche wrote:
> On Sun, 2018-05-20 at 19:21 -0400, Kent Overstreet wrote:
> > I really have better things to do than debug someone else's tests...
> > [ ... ]
> > ../run_tests: line 65: cd: /lib/modules/4.16.0+/kernel/block: No such file or directory
> 
> Kernel v4.16 is too old to run these tests. The srp-test script needs the
> following commit that went upstream in kernel v4.17-rc1:
> 
> 63cf1a902c9d ("IB/srpt: Add RDMA/CM support")

Same output on Jens' for-next branch.
