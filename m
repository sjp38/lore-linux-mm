Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF6036B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:21:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14-v6so4351905wrq.4
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:21:32 -0700 (PDT)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id o14-v6si12076995wrj.227.2018.06.07.15.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:21:31 -0700 (PDT)
Subject: Re: [PATCH] xsk: Fix umem fill/completion queue mmap on 32-bit
References: <1528378654-1484-1-git-send-email-geert@linux-m68k.org>
 <CAJ+HfNiciU0+4zd3ppapH12Gg_SFf9oUWTy+yafJSxCX8Mv-Dg@mail.gmail.com>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <67dd01ce-2aa8-6e33-326e-6b57b3c6d67b@iogearbox.net>
Date: Fri, 8 Jun 2018 00:21:23 +0200
MIME-Version: 1.0
In-Reply-To: <CAJ+HfNiciU0+4zd3ppapH12Gg_SFf9oUWTy+yafJSxCX8Mv-Dg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>, geert@linux-m68k.org
Cc: David Miller <davem@davemloft.net>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, ast@kernel.org, Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org, Netdev <netdev@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 06/07/2018 06:34 PM, BjA?rn TA?pel wrote:
> Den tors 7 juni 2018 kl 15:37 skrev Geert Uytterhoeven <geert@linux-m68k.org>:
>>
>> With gcc-4.1.2 on 32-bit:
>>
>>     net/xdp/xsk.c:663: warning: integer constant is too large for a??longa?? type
>>     net/xdp/xsk.c:665: warning: integer constant is too large for a??longa?? type
>>
>> Add the missing "ULL" suffixes to the large XDP_UMEM_PGOFF_*_RING values
>> to fix this.
>>
>>     net/xdp/xsk.c:663: warning: comparison is always false due to limited range of data type
>>     net/xdp/xsk.c:665: warning: comparison is always false due to limited range of data type
>>
>> "unsigned long" is 32-bit on 32-bit systems, hence the offset is
>> truncated, and can never be equal to any of the XDP_UMEM_PGOFF_*_RING
>> values.  Use loff_t (and the required cast) to fix this.
>>
>> Fixes: 423f38329d267969 ("xsk: add umem fill queue support and mmap")
>> Fixes: fe2308328cd2f26e ("xsk: add umem completion queue support and mmap")
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
[...]
> 
> Thanks Geert!
> 
> Acked-by: BjA?rn TA?pel <bjorn.topel@intel.com>

Applied to bpf, thanks everyone!
