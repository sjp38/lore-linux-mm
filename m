Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2C46B007E
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 12:53:49 -0400 (EDT)
Received: by mail-io0-f179.google.com with SMTP id 2so183099741ioy.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 09:53:49 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id l87si13587434iod.62.2016.04.10.09.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Apr 2016 09:53:48 -0700 (PDT)
Received: by mail-ig0-x22a.google.com with SMTP id g8so54067854igr.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 09:53:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160410075550.GA22873@pox.localdomain>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<20160408123614.2a15a346@redhat.com>
	<20160408143340.10e5b1d0@redhat.com>
	<20160408172651.GA38264@ast-mbp.thefacebook.com>
	<20160408220808.682630d7@redhat.com>
	<20160408213414.GA43408@ast-mbp.thefacebook.com>
	<CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
	<57091FCE.50104@mojatatu.com>
	<20160409172634.GA55330@ast-mbp.thefacebook.com>
	<20160410075550.GA22873@pox.localdomain>
Date: Sun, 10 Apr 2016 09:53:48 -0700
Message-ID: <CALx6S37gzDE0-S4JjS3m+FyuA2xypyp+O+XYdeK3ciAnvmmkyQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver filter
From: Tom Herbert <tom@herbertland.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Graf <tgraf@suug.ch>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Jamal Hadi Salim <jhs@mojatatu.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller" <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>, john fastabend <john.fastabend@gmail.com>, Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>

On Sun, Apr 10, 2016 at 12:55 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 04/09/16 at 10:26am, Alexei Starovoitov wrote:
>> On Sat, Apr 09, 2016 at 11:29:18AM -0400, Jamal Hadi Salim wrote:
>> > If this is _forwarding only_ it maybe useful to look at
>> > Alexey's old code in particular the DMA bits;
>> > he built his own lookup algorithm but sounds like bpf is
>> > a much better fit today.
>>
>> a link to these old bits?
>>
>> Just to be clear: this rfc is not the only thing we're considering.
>> In particular huawei guys did a monster effort to improve performance
>> in this area as well. We'll try to blend all the code together and
>> pick what's the best.
>
> What's the plan on opening the discussion on this? Can we get a peek?
> Is it an alternative to XDP and the driver hook? Different architecture
> or just different implementation? I understood it as another pseudo
> skb model with a path on converting to real skbs for stack processing.
>
We started discussions about this in IOvisor. The Huawei project is
called ceth (Common Ethernet). It is essentially a layer called
directly from drivers intended for fast path forwarding and network
virtualization. They have put quite a bit of effort into buffer
management and other parts of the infrastructure, much of which we
would like to leverage in XDP. The code is currently in github, will
ask them to make it generally accessible.

The programmability part, essentially BPF, should be part of a common
solution. We can define the necessary interfaces independently of the
underlying infrastructure which is really the only way we can do this
if we want the BPF programs to be portable across different
platforms-- in Linux, userspace, HW, etc.

Tom

> I really like the current proposal by Brenden for its simplicity and
> targeted compatibility with cls_bpf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
