Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8983428045A
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 20:24:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so15326398pfj.2
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 17:24:28 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id c1si816867pld.698.2017.09.06.17.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Sep 2017 17:24:26 -0700 (PDT)
Date: Thu, 7 Sep 2017 10:24:23 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-09-06-17-01 uploaded
Message-ID: <20170907102423.4bac0d31@canb.auug.org.au>
In-Reply-To: <59b08c79.TDHrzX7XqqIJyQ3V%akpm@linux-foundation.org>
References: <59b08c79.TDHrzX7XqqIJyQ3V%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Wed, 06 Sep 2017 17:02:01 -0700 akpm@linux-foundation.org wrote:
>
> * x509-fix-the-buffer-overflow-in-the-utility-function-for-oid-string.patch

The above patch has a space with its high bit set in the From: line which
"git am" doesn't like.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
