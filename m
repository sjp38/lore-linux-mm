Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC8626B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:22:29 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f9-v6so7661844plo.17
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:22:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x5-v6si1016103plv.293.2018.04.09.13.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 13:22:28 -0700 (PDT)
Subject: Re: [PATCH] Documentation/vm/hmm.txt: typos and syntaxes fixes
References: <20180409151859.4713-1-jglisse@redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a23b6758-6720-092a-994e-e4f67263425b@infradead.org>
Date: Mon, 9 Apr 2018 13:22:21 -0700
MIME-Version: 1.0
In-Reply-To: <20180409151859.4713-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Ralph Campbell <rcampbell@nvidia.com>

On 04/09/18 08:18, jglisse@redhat.com wrote:
> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> This fix typos and syntaxes, thanks to Randy Dunlap for pointing them
> out (they were all my faults).
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  Documentation/vm/hmm.txt | 108 +++++++++++++++++++++++------------------------
>  1 file changed, 54 insertions(+), 54 deletions(-)

Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

thanks.
-- 
~Randy
