Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAEA6B025E
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 23:48:01 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so111413441pac.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 20:48:01 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id dx9si15061990pab.202.2015.12.29.20.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 20:48:00 -0800 (PST)
Received: by mail-pa0-x244.google.com with SMTP id gi1so16079749pac.2
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 20:48:00 -0800 (PST)
Date: Wed, 30 Dec 2015 10:17:50 +0530
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()
Message-ID: <20151230044750.GA18675@sudip-pc>
References: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Clayton <stillcompiling@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, linux-mm@kvack.org, lustre-devel@lists.lustre.org

On Sat, Dec 26, 2015 at 09:12:42PM -0800, Joshua Clayton wrote:
> running sparse on drivers/staging/lustre results in dozens of warnings:
> include/linux/gfp.h:281:41: warning:
> odd constant _Bool cast (400000 becomes 1)
> 
> Use "!!" to explicitly convert the result to bool range.
> ---

Signed-off-by missing.

regards
sudip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
