Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C33F6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 21:20:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 65so2266612wrn.7
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 18:20:27 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 36si14189919wrj.417.2018.03.07.18.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 18:20:26 -0800 (PST)
Subject: Re: mmotm 2018-03-07-16-19 uploaded (UML & memcg)
References: <20180308002016.L3JwBaNZ9%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <41ec9eeb-f0bf-e26d-e3ae-4a684c314360@infradead.org>
Date: Wed, 7 Mar 2018 18:20:12 -0800
MIME-Version: 1.0
In-Reply-To: <20180308002016.L3JwBaNZ9%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, Shakeel Butt <shakeelb@google.com>

On 03/07/2018 04:20 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-03-07-16-19 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.

UML on i386 and/or x86_64:

defconfig, CONFIG_MEMCG is not set:

../fs/notify/group.c: In function 'fsnotify_final_destroy_group':
../fs/notify/group.c:41:24: error: dereferencing pointer to incomplete type
   css_put(&group->memcg->css);
                        ^

From: Shakeel Butt <shakeelb@google.com>
Subject: fs: fsnotify: account fsnotify metadata to kmemcg


-- 
~Randy
