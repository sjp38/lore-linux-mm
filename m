Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B86F6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 20:23:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17-v6so3743201pfm.18
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 17:23:48 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 29-v6si6455734pfs.40.2018.06.14.17.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 17:23:45 -0700 (PDT)
Subject: Re: [PATCH] doc: add description to dirtytime_expire_seconds
References: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <e4cfd434-4ed3-8f27-5f95-d570cfe118ae@linux.alibaba.com>
Date: Thu, 14 Jun 2018 17:23:25 -0700
MIME-Version: 1.0
In-Reply-To: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu, corbet@lwn.net, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ping


Ted,


Any comment is appreciated.


Regards,

Yang



On 5/30/18 4:56 PM, Yang Shi wrote:
> commit 1efff914afac8a965ad63817ecf8861a927c2ace ("fs: add
> dirtytime_expire_seconds sysctl") introduced dirtytime_expire_seconds
> knob, but there is not description about it in
> Documentation/sysctl/vm.txt.
>
> Add the description for it.
>
> Cc: Theodore Ts'o <tytso@mit.edu>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> I didn't dig into the old review discussion about why the description
> was not added at the first place. I'm supposed every knob under /proc/sys
> should have a brief description.
>
>   Documentation/sysctl/vm.txt | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 17256f2..f4f4f9c 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -27,6 +27,7 @@ Currently, these files are in /proc/sys/vm:
>   - dirty_bytes
>   - dirty_expire_centisecs
>   - dirty_ratio
> +- dirtytime_expire_seconds
>   - dirty_writeback_centisecs
>   - drop_caches
>   - extfrag_threshold
> @@ -178,6 +179,16 @@ The total available memory is not equal to total system memory.
>   
>   ==============================================================
>   
> +dirtytime_expire_seconds
> +
> +When a lazytime inode is constantly having its pages dirtied, it with an
> +updated timestamp will never get chance to be written out.  This tunable
> +is used to define when dirty inode is old enough to be eligible for
> +writeback by the kernel flusher threads. And, it is also used as the
> +interval to wakeup dirtytime_writeback thread. It is expressed in seconds.
> +
> +==============================================================
> +
>   dirty_writeback_centisecs
>   
>   The kernel flusher threads will periodically wake up and write `old' data
