Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA6962802AF
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 21:01:14 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id x28so71926ita.9
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 18:01:14 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e2si2456073itc.83.2017.11.10.18.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 18:01:12 -0800 (PST)
Subject: Re: mmotm 2017-11-10-15-56 uploaded (lib/test_find_bit.c)
References: <5a063cc8.w9SFxvjWsZNJM4HP%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2ce9cf55-2b54-b6cd-fa4d-3cd0a354b5f1@infradead.org>
Date: Fri, 10 Nov 2017 18:00:57 -0800
MIME-Version: 1.0
In-Reply-To: <5a063cc8.w9SFxvjWsZNJM4HP%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, Yury Norov <ynorov@caviumnetworks.com>

On 11/10/2017 03:56 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2017-11-10-15-56 has been uploaded to
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

on i386:

../lib/test_find_bit.c:54:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
../lib/test_find_bit.c:68:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
../lib/test_find_bit.c:82:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]
../lib/test_find_bit.c:102:2: warning: format '%ld' expects argument of type 'long int', but argument 2 has type 'cycles_t' [-Wformat=]



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
