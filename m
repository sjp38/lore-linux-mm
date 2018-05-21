Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 621D56B0005
	for <linux-mm@kvack.org>; Sun, 20 May 2018 20:49:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w8-v6so301628wrn.10
        for <linux-mm@kvack.org>; Sun, 20 May 2018 17:49:16 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id e15-v6si9450154eda.181.2018.05.20.17.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 17:49:15 -0700 (PDT)
Subject: Re: mmotm 2018-05-17-16-26 uploaded (autofs)
From: Ian Kent <raven@themaw.net>
References: <20180517232639.sD6Cz%akpm@linux-foundation.org>
 <19926e1e-6dba-3b9f-fd97-d9eb88bfb7dd@infradead.org>
 <49acf718-da2e-73dc-a3bf-c41d7546576e@themaw.net>
 <9e3dfece-46a0-8ab2-2c7e-3edf956703a8@infradead.org>
 <6441e45b-6216-a20a-5b1d-6f5663d701dd@themaw.net>
 <80c2dcf5-b9a9-3d75-7f6f-d0e9c1a11fb9@themaw.net>
 <22ae3b7e-bfbd-6537-9656-9fd429255d69@infradead.org>
 <d225202d-fcba-851d-63a6-ae6a1c3ae0e7@themaw.net>
Message-ID: <11712bc6-9d45-7bb1-4e88-720ee3e312dd@themaw.net>
Date: Mon, 21 May 2018 08:49:08 +0800
MIME-Version: 1.0
In-Reply-To: <d225202d-fcba-851d-63a6-ae6a1c3ae0e7@themaw.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On 21/05/18 08:43, Ian Kent wrote:
>>>
>>> It looks like adding:
>>> depends on AUTOFS_FS = n && AUTOFS_FS != m
>>
>> Hi.  Is there a typo on the line above?

LOL, but your point is what does the AUTOFS_FS != m do!

The answer should be nothing but ..... I'll have to play
a little more.

> 
> Don't think so.
> 
> This was straight out of:
> 
> diff --git a/fs/autofs4/Kconfig b/fs/autofs4/Kconfig
> index 53bc592a250d..2f9bafabac1b 100644
> --- a/fs/autofs4/Kconfig
> +++ b/fs/autofs4/Kconfig
> @@ -1,6 +1,7 @@
>  config AUTOFS4_FS
>         tristate "Kernel automounter version 4 support (also supports v3 and v5)"
>         default n
> +       depends on AUTOFS_FS = n && AUTOFS_FS != m
>         help
>           The automounter is a tool to automatically mount remote file systems
>           on demand. This implementation is partially kernel-based to reduce
> @@ -30,3 +31,10 @@ config AUTOFS4_FS
>           - any "alias autofs autofs4" will need to be removed.
>  
>           Please configure AUTOFS_FS instead of AUTOFS4_FS from now on.
> +
> +         NOTE: Since the modules autofs and autofs4 use the same file system
> +               type name of "autofs" only one can be built. The "depends"
> +               above will result in AUTOFS4_FS not appearing in .config for
> +               any setting of AUTOFS_FS other than n and AUTOFS4_FS will
> +               appear under the AUTOFS_FS entry otherwise which is intended
> +               to draw attention to the module rename change.
> 
> which appears to do what's needed about as well as can be done and deals
> with the AUTOFS4_FS=y && AUTOFS_FS=y case.
> 
> Ian
> 
