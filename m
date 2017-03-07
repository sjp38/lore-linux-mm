Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA5A96B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 21:07:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o126so54515548pfb.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 18:07:59 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 61si20820622plz.89.2017.03.06.18.07.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Mar 2017 18:07:58 -0800 (PST)
Date: Tue, 7 Mar 2017 13:07:55 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-03-06-16-52 uploaded
Message-ID: <20170307130755.29ccd1b1@canb.auug.org.au>
In-Reply-To: <58be0472.psWRZiN5XRSmRqWR%akpm@linux-foundation.org>
References: <58be0472.psWRZiN5XRSmRqWR%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Mon, 06 Mar 2017 16:53:06 -0800 akpm@linux-foundation.org wrote:
>
>   linux-next-rejects.patch

Just wondering why this includes "struct iomap" -> "const struct iomap"
conversions when they should just be done in a regular patch.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
