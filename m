Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABE4B6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:54:02 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id m134so4985876lfg.12
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:54:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65sor996868lfv.98.2017.12.20.00.54.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 00:54:01 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz> <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV>
From: A K <akaraliou.dev@gmail.com>
Message-ID: <c53d8fcd-7e7e-1dc0-c892-deb2514b8891@gmail.com>
Date: Wed, 20 Dec 2017 11:53:58 +0300
MIME-Version: 1.0
In-Reply-To: <20171220083403.GC11774@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On 12/20/2017 11:34 AM, Sergey Senozhatsky wrote:

> On (12/20/17 11:29), A K wrote:
> [..]
>> May we leave previous variant to avoid that ? Or it is not critical ?
> let's keep void zs_register_shrinker() and just suppress the
> register_shrinker() must_check warning.
>
> 	-ss
IMHO, It seems that there is no obvious way to suppress this like casting to void.
We can probably add pr_debug/warn in order to use the result somehow.

Best regards,
    Aliaksei.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
