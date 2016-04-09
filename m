Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E18946B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 11:29:21 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id f1so32853649igr.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 08:29:21 -0700 (PDT)
Received: from mail-ig0-x244.google.com (mail-ig0-x244.google.com. [2607:f8b0:4001:c05::244])
        by mx.google.com with ESMTPS id 10si9838971ioq.39.2016.04.09.08.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 08:29:21 -0700 (PDT)
Received: by mail-ig0-x244.google.com with SMTP id nt3so6065916igb.0
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 08:29:20 -0700 (PDT)
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com> <20160408143340.10e5b1d0@redhat.com>
 <20160408172651.GA38264@ast-mbp.thefacebook.com>
 <20160408220808.682630d7@redhat.com>
 <20160408213414.GA43408@ast-mbp.thefacebook.com>
 <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
From: Jamal Hadi Salim <jhs@mojatatu.com>
Message-ID: <57091FCE.50104@mojatatu.com>
Date: Sat, 9 Apr 2016 11:29:18 -0400
MIME-Version: 1.0
In-Reply-To: <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller" <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>, john fastabend <john.fastabend@gmail.com>, Thomas Graf <tgraf@suug.ch>, Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>

On 16-04-09 07:29 AM, Tom Herbert wrote:

> +1. Forwarding which will be a common application almost always
> requires modification (decrement TTL), and header data split has
> always been a weak feature since the device has to have some arbitrary
> rules about what headers needs to be split out (either implements
> protocol specific parsing or some fixed length).

Then this is sensible. I was cruising the threads and
confused by your earlier emails Tom because you talked
about XPS etc. It sounded like the idea evolved into putting
the whole freaking stack on bpf.
If this is _forwarding only_ it maybe useful to look at
Alexey's old code in particular the DMA bits;
he built his own lookup algorithm but sounds like bpf is
a much better fit today.

cheers,
jamal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
