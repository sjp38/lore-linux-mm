Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E33766B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 03:05:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 76-v6so748577wmw.3
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 00:05:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si3282976edh.423.2018.06.15.00.05.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jun 2018 00:05:00 -0700 (PDT)
Subject: Re: [PATCH] doc: add description to dirtytime_expire_seconds
References: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <5a1efc1b-c586-616f-1668-b4b8f24f873a@suse.com>
Date: Fri, 15 Jun 2018 10:04:57 +0300
MIME-Version: 1.0
In-Reply-To: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, tytso@mit.edu, corbet@lwn.net, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 31.05.2018 02:56, Yang Shi wrote:
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
>  Documentation/sysctl/vm.txt | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 17256f2..f4f4f9c 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -27,6 +27,7 @@ Currently, these files are in /proc/sys/vm:
>  - dirty_bytes
>  - dirty_expire_centisecs
>  - dirty_ratio
> +- dirtytime_expire_seconds
>  - dirty_writeback_centisecs
>  - drop_caches
>  - extfrag_threshold
> @@ -178,6 +179,16 @@ The total available memory is not equal to total system memory.
>  
>  ==============================================================
>  
> +dirtytime_expire_seconds
> +
> +When a lazytime inode is constantly having its pages dirtied, it with an

The second part of this sentence, after the comma doesn't parse.

> +updated timestamp will never get chance to be written out.  This tunable
> +is used to define when dirty inode is old enough to be eligible for
> +writeback by the kernel flusher threads. And, it is also used as the
> +interval to wakeup dirtytime_writeback thread. It is expressed in seconds.

I think the final sentence is a bit redundant, given the very explicit
name of the knob.

> +
> +==============================================================
> +
>  dirty_writeback_centisecs
>  
>  The kernel flusher threads will periodically wake up and write `old' data
> 
