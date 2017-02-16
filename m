Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47785681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:03:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r207so32723254pgr.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:03:59 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id y11si4615145plg.84.2017.02.16.11.03.58
        for <linux-mm@kvack.org>;
        Thu, 16 Feb 2017 11:03:58 -0800 (PST)
Date: Thu, 16 Feb 2017 14:03:55 -0500 (EST)
Message-Id: <20170216.140355.2079700662225068523.davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: David Miller <davem@davemloft.net>
In-Reply-To: <CALx6S36xcEJ9YssZtzQKOy-tufrWWJO533J0nTEzp_ckb5dVjA@mail.gmail.com>
References: <CANn89iJip45peBQB9Tn1mWVg+1QYZH+01CqkAUctd3xqwPw8Zg@mail.gmail.com>
	<37bc04eb-71c9-0433-304d-87fcf8b06be3@mellanox.com>
	<CALx6S36xcEJ9YssZtzQKOy-tufrWWJO533J0nTEzp_ckb5dVjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tom@herbertland.com
Cc: tariqt@mellanox.com, edumazet@google.com, brouer@redhat.com, eric.dumazet@gmail.com, alexander.duyck@gmail.com, netdev@vger.kernel.org, kafai@fb.com, saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com, ast@kernel.org, linux-mm@kvack.org

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 16 Feb 2017 09:05:26 -0800

> On Thu, Feb 16, 2017 at 5:08 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>
>> On 15/02/2017 6:57 PM, Eric Dumazet wrote:
>>>
>>> On Wed, Feb 15, 2017 at 8:42 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>>>
>>>> Isn't it the same principle in page_frag_alloc() ?
>>>> It is called form __netdev_alloc_skb()/__napi_alloc_skb().
>>>>
>>>> Why is it ok to have order-3 pages (PAGE_FRAG_CACHE_MAX_ORDER) there?
>>>
>>> This is not ok.
>>>
>>> This is a very well known problem, we already mentioned that here in the
>>> past,
>>> but at least core networking stack uses  order-0 pages on PowerPC.
>>
>> You're right, we should have done this as well in mlx4 on PPC.
>>>
>>> mlx4 driver suffers from this problem 100% more than other drivers ;)
>>>
>>> One problem at a time Tariq. Right now, only mlx4 has this big problem
>>> compared to other NIC.
>>
>> We _do_ agree that the series improves the driver's quality, stability,
>> and performance in a fragmented system.
>>
>> But due to the late rc we're in, and the fact that we know what benchmarks
>> our customers are going to run, we cannot Ack the series and get it
>> as is inside kernel 4.11.
>>
> You're admitting that Eric's patches improve driver quality,
> stability, and performance but you're not allowing this in the kernel
> because "we know what benchmarks our customers are going to run".
> Sorry, but that is a weak explanation.

I have to agree with Tom and Eric.

If your customers have gotten into the habit of using metrics which
actually do not represent real life performance, that is a completely
inappropriate reason to not include Eric's changes as-is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
