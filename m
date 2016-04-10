Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 37EA66B0005
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 03:55:54 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l6so108996061wml.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 00:55:54 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id o130si11950770wme.64.2016.04.10.00.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Apr 2016 00:55:52 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id n3so67537823wmn.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 00:55:52 -0700 (PDT)
Date: Sun, 10 Apr 2016 09:55:50 +0200
From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Message-ID: <20160410075550.GA22873@pox.localdomain>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com>
 <20160408143340.10e5b1d0@redhat.com>
 <20160408172651.GA38264@ast-mbp.thefacebook.com>
 <20160408220808.682630d7@redhat.com>
 <20160408213414.GA43408@ast-mbp.thefacebook.com>
 <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
 <57091FCE.50104@mojatatu.com>
 <20160409172634.GA55330@ast-mbp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160409172634.GA55330@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Tom Herbert <tom@herbertland.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller" <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>, john fastabend <john.fastabend@gmail.com>, Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>

On 04/09/16 at 10:26am, Alexei Starovoitov wrote:
> On Sat, Apr 09, 2016 at 11:29:18AM -0400, Jamal Hadi Salim wrote:
> > If this is _forwarding only_ it maybe useful to look at
> > Alexey's old code in particular the DMA bits;
> > he built his own lookup algorithm but sounds like bpf is
> > a much better fit today.
> 
> a link to these old bits?
> 
> Just to be clear: this rfc is not the only thing we're considering.
> In particular huawei guys did a monster effort to improve performance
> in this area as well. We'll try to blend all the code together and
> pick what's the best.

What's the plan on opening the discussion on this? Can we get a peek?
Is it an alternative to XDP and the driver hook? Different architecture
or just different implementation? I understood it as another pseudo
skb model with a path on converting to real skbs for stack processing.

I really like the current proposal by Brenden for its simplicity and
targeted compatibility with cls_bpf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
