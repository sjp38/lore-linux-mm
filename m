Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D301681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 16:06:39 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y2so22608114qkb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:06:39 -0800 (PST)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id m48si6083203qtb.102.2017.02.16.13.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 13:06:38 -0800 (PST)
Received: by mail-qk0-x241.google.com with SMTP id p22so4115052qka.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:06:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170216.140355.2079700662225068523.davem@davemloft.net>
References: <CANn89iJip45peBQB9Tn1mWVg+1QYZH+01CqkAUctd3xqwPw8Zg@mail.gmail.com>
 <37bc04eb-71c9-0433-304d-87fcf8b06be3@mellanox.com> <CALx6S36xcEJ9YssZtzQKOy-tufrWWJO533J0nTEzp_ckb5dVjA@mail.gmail.com>
 <20170216.140355.2079700662225068523.davem@davemloft.net>
From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Thu, 16 Feb 2017 23:06:17 +0200
Message-ID: <CALzJLG9WaWks_DrLkLZaXc1VRNnmUqg8RDMscwCgqvN0xFBm2g@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Tom Herbert <tom@herbertland.com>, Tariq Toukan <tariqt@mellanox.com>, Eric Dumazet <edumazet@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexander Duyck <alexander.duyck@gmail.com>, Linux Netdev List <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, Feb 16, 2017 at 9:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 16 Feb 2017 09:05:26 -0800
>
>> On Thu, Feb 16, 2017 at 5:08 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>>
>>> On 15/02/2017 6:57 PM, Eric Dumazet wrote:
>>>>
>>>> On Wed, Feb 15, 2017 at 8:42 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>>>>
>>>>> Isn't it the same principle in page_frag_alloc() ?
>>>>> It is called form __netdev_alloc_skb()/__napi_alloc_skb().
>>>>>
>>>>> Why is it ok to have order-3 pages (PAGE_FRAG_CACHE_MAX_ORDER) there?
>>>>
>>>> This is not ok.
>>>>
>>>> This is a very well known problem, we already mentioned that here in the
>>>> past,
>>>> but at least core networking stack uses  order-0 pages on PowerPC.
>>>
>>> You're right, we should have done this as well in mlx4 on PPC.
>>>>
>>>> mlx4 driver suffers from this problem 100% more than other drivers ;)
>>>>
>>>> One problem at a time Tariq. Right now, only mlx4 has this big problem
>>>> compared to other NIC.
>>>
>>> We _do_ agree that the series improves the driver's quality, stability,
>>> and performance in a fragmented system.
>>>
>>> But due to the late rc we're in, and the fact that we know what benchmarks
>>> our customers are going to run, we cannot Ack the series and get it
>>> as is inside kernel 4.11.
>>>
>> You're admitting that Eric's patches improve driver quality,
>> stability, and performance but you're not allowing this in the kernel
>> because "we know what benchmarks our customers are going to run".
>> Sorry, but that is a weak explanation.
>
> I have to agree with Tom and Eric.
>
> If your customers have gotten into the habit of using metrics which
> actually do not represent real life performance, that is a completely
> inappropriate reason to not include Eric's changes as-is.

Guys, It is not about customers, benchmark and great performance numbers.
We agree with you that those patches are good and needed for the long term,
but as we are already at rc8 and although this change is correct, i
think it is a little bit too late
to have such huge change in the core RX engine of the driver. ( the
code is already like this for
more kernel releases than one could count, it will hurt no one to keep
it like this for two weeks more).

All we ask is to have a little bit more time - one or two weeks- to
test them and evaluate the impact.
As Eric stated we don't care if they make it to 4.11 or 4.12, the idea
is to have them in ASAP.
so why not wait to 4.11 (just two more weeks) and Tariq already said
that he will accept it as is.
and by then we will be smarter and have a clear plan of the gaps and
how to close them.

For PowerPC page order issue, Eric already have a simpler suggestion
that i support, and can easily be
sent to net and -stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
