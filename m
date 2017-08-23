Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10D972803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:46:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so19967842pgr.6
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:46:18 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id q132si1707518pgq.493.2017.08.23.16.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 Aug 2017 16:46:16 -0700 (PDT)
Date: Thu, 24 Aug 2017 09:46:13 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-08-23-16-26 uploaded
Message-ID: <20170824094613.7873bf32@canb.auug.org.au>
In-Reply-To: <599e0f5f.qB5Zs5tdsBajmNob%akpm@linux-foundation.org>
References: <599e0f5f.qB5Zs5tdsBajmNob%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Wed, 23 Aug 2017 16:27:27 -0700 akpm@linux-foundation.org wrote:
>
> * mm-page_alloc-rip-out-zonelist_order_zone-fix.patch

That patch has an "Author:" line instead of a "From:" line ("git am" objects).

Otherwise looks good.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
