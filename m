Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A686A6B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 13:26:43 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bx7so77362089pad.3
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 10:26:43 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id q188si8028624pfq.49.2016.04.09.10.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 10:26:42 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id n1so95317326pfn.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 10:26:42 -0700 (PDT)
Date: Sat, 9 Apr 2016 10:26:37 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Message-ID: <20160409172634.GA55330@ast-mbp.thefacebook.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com>
 <20160408143340.10e5b1d0@redhat.com>
 <20160408172651.GA38264@ast-mbp.thefacebook.com>
 <20160408220808.682630d7@redhat.com>
 <20160408213414.GA43408@ast-mbp.thefacebook.com>
 <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
 <57091FCE.50104@mojatatu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57091FCE.50104@mojatatu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller" <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>, john fastabend <john.fastabend@gmail.com>, Thomas Graf <tgraf@suug.ch>, Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>

On Sat, Apr 09, 2016 at 11:29:18AM -0400, Jamal Hadi Salim wrote:
> On 16-04-09 07:29 AM, Tom Herbert wrote:
> 
> >+1. Forwarding which will be a common application almost always
> >requires modification (decrement TTL), and header data split has
> >always been a weak feature since the device has to have some arbitrary
> >rules about what headers needs to be split out (either implements
> >protocol specific parsing or some fixed length).
> 
> Then this is sensible. I was cruising the threads and
> confused by your earlier emails Tom because you talked
> about XPS etc. It sounded like the idea evolved into putting
> the whole freaking stack on bpf.

yeah, no stack, no queues in bpf.

> If this is _forwarding only_ it maybe useful to look at
> Alexey's old code in particular the DMA bits;
> he built his own lookup algorithm but sounds like bpf is
> a much better fit today.

a link to these old bits?

Just to be clear: this rfc is not the only thing we're considering.
In particular huawei guys did a monster effort to improve performance
in this area as well. We'll try to blend all the code together and
pick what's the best.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
