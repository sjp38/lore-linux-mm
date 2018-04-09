Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E98FA6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 04:26:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p189so4780795pfp.1
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 01:26:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j61-v6si14312458plb.317.2018.04.09.01.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 01:26:53 -0700 (PDT)
Date: Mon, 9 Apr 2018 01:26:50 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Block layer use of __GFP flags
Message-ID: <20180409082650.GA869@infradead.org>
References: <20180408065425.GD16007@bombadil.infradead.org>
 <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
 <20180408190825.GC5704@bombadil.infradead.org>
 <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
 <20180409085349.31b10550@pentland.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409085349.31b10550@pentland.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hannes Reinecke <hare@suse.de>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "willy@infradead.org" <willy@infradead.org>, "axboe@kernel.dk" <axboe@kernel.dk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

On Mon, Apr 09, 2018 at 08:53:49AM +0200, Hannes Reinecke wrote:
> Why don't you fold the 'flags' argument into the 'gfp_flags', and drop
> the 'flags' argument completely?
> Looks a bit pointless to me, having two arguments denoting basically
> the same ...

Wrong way around.  gfp_flags doesn't really make much sense in this
context.  We just want the plain flags argument, including a non-block
flag for it.
