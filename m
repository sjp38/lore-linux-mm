Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA466B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 19:11:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so53826415pgc.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 16:11:28 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z4si21355989pgo.126.2016.12.06.16.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Dec 2016 16:11:27 -0800 (PST)
Date: Wed, 7 Dec 2016 11:11:23 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2016-11-30-15-46 uploaded
Message-ID: <20161207111123.61a3f921@canb.auug.org.au>
In-Reply-To: <20161201114431.2a2cb11d@canb.auug.org.au>
References: <583f6515.fNq/FWln01oGaTxN%akpm@linux-foundation.org>
	<20161201114431.2a2cb11d@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Thu, 1 Dec 2016 11:44:31 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Wed, 30 Nov 2016 15:47:33 -0800 akpm@linux-foundation.org wrote:
> >
> > * ima-define-a-canonical-binary_runtime_measurements-list-format.patch  
> 
> This patch tries to patch the file
> 
>   Documentation/kernel-parameters.txt
> 
> but that file has been renamed to
> 
>   Documentation/admin-guide/kernel-parameters.rst
> 
> in linux-next.  I just dropped the hunk from the patch.

I dropped this hunk again.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
