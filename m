Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 638A36B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 19:44:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so327804868pfv.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:44:36 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z15si66518310pfj.14.2016.11.30.16.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Nov 2016 16:44:35 -0800 (PST)
Date: Thu, 1 Dec 2016 11:44:31 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2016-11-30-15-46 uploaded
Message-ID: <20161201114431.2a2cb11d@canb.auug.org.au>
In-Reply-To: <583f6515.fNq/FWln01oGaTxN%akpm@linux-foundation.org>
References: <583f6515.fNq/FWln01oGaTxN%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Wed, 30 Nov 2016 15:47:33 -0800 akpm@linux-foundation.org wrote:
>
> * ima-define-a-canonical-binary_runtime_measurements-list-format.patch

This patch tries to patch the file

  Documentation/kernel-parameters.txt

but that file has been renamed to

  Documentation/admin-guide/kernel-parameters.rst

in linux-next.  I just dropped the hunk from the patch.
-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
