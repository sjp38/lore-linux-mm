Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CED486810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 19:50:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z193so4676099pgd.10
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 16:50:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p5si5458914pgn.350.2017.08.25.16.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 16:50:32 -0700 (PDT)
Subject: Re: mmotm 2017-08-25-15-50 uploaded
References: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
Date: Fri, 25 Aug 2017 16:50:26 -0700
MIME-Version: 1.0
In-Reply-To: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 08/25/17 15:50, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2017-08-25-15-50 has been uploaded to
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

lots of this one (on x86_64, i386, or UML):

../kernel/fork.c:818:2: error: implicit declaration of function 'hmm_mm_init' [-Werror=implicit-function-declaration]
../kernel/fork.c:897:2: error: implicit declaration of function 'hmm_mm_destroy' [-Werror=implicit-function-declaration]

from mm-hmm-heterogeneous-memory-management-hmm-for-short-v5.patch

Cc: JA(C)rA'me Glisse <jglisse@redhat.com>

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
