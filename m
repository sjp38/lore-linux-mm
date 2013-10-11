Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 113E26B0037
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 05:25:41 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3975753pdj.15
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 02:25:41 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUH00544ZIB9E00@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 Oct 2013 10:25:37 +0100 (BST)
Message-id: <1381483536.2736.4.camel@AMDC1943>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Fri, 11 Oct 2013 11:25:36 +0200
In-reply-to: <CAL1ERfOnb7DZXH87cq2ZWhRiDuU9btmmRbOURLA5SV7zsho1VA@mail.gmail.com>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
 <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
 <1381220000.16135.10.camel@AMDC1943>
 <20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org>
 <20131009144045.GA5406@variantweb.net> <525602E3.3080501@oracle.com>
 <20131010022627.GA8535@variantweb.net>
 <CAL1ERfOnb7DZXH87cq2ZWhRiDuU9btmmRbOURLA5SV7zsho1VA@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <spartacus06@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Fri, 2013-10-11 at 10:23 +0800, Weijie Yang wrote:
> I am sorry to interrupt this topic, but I found an tiny issue near that:
> 
> we can not "set_blocksize(bdev, p->old_block_size);" at the end of swapoff()
> because swap_info p may be reused by concurrent swapon called
> I think we need to  save the p->old_block_size in a local var and use it instead
I confirm the race here (I was able to trigger it on the same swap type).


> to Krzysztof : would you please add this in your patch?
> Thanks
I think it should be another patch as this is not related with
frontswap. I'll send new one and add you as Reported-by. Is it OK with
you?


Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
