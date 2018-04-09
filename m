Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 763F16B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 02:53:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x184so2912846pfd.14
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 23:53:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si10650227pgs.685.2018.04.08.23.53.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 Apr 2018 23:53:53 -0700 (PDT)
Date: Mon, 9 Apr 2018 08:53:49 +0200
From: Hannes Reinecke <hare@suse.de>
Subject: Re: Block layer use of __GFP flags
Message-ID: <20180409085349.31b10550@pentland.suse.de>
In-Reply-To: <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
References: <20180408065425.GD16007@bombadil.infradead.org>
	<aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
	<20180408190825.GC5704@bombadil.infradead.org>
	<63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "willy@infradead.org" <willy@infradead.org>, "axboe@kernel.dk" <axboe@kernel.dk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

On Mon, 9 Apr 2018 04:46:22 +0000
"Bart Van Assche" <Bart.VanAssche@wdc.com> wrote:

> On Sun, 2018-04-08 at 12:08 -0700, Matthew Wilcox wrote:
> > On Sun, Apr 08, 2018 at 04:40:59PM +0000, Bart Van Assche wrote:  
> > > Do you perhaps want me to prepare a patch that makes
> > > blk_get_request() again respect the full gfp mask passed as third
> > > argument to blk_get_request()?  
> > 
> > I think that would be a good idea.  If it's onerous to have extra
> > arguments, there are some bits in gfp_flags which could be used for
> > your purposes.  
> 
> That's indeed something we can consider.
> 
> It would be appreciated if you could have a look at the patch below.
> 
> Thanks,
> 
> Bart.
> 
> 

Why don't you fold the 'flags' argument into the 'gfp_flags', and drop
the 'flags' argument completely?
Looks a bit pointless to me, having two arguments denoting basically
the same ...

Cheers,

Hannes
