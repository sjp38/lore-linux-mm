Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id F16D86B025E
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 23:54:27 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id v14so53609655ykd.3
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 20:54:27 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id x65si2621200ywe.314.2015.12.29.20.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 20:54:27 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id x67so145521747ykd.2
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 20:54:27 -0800 (PST)
From: Joshua Clayton <stillcompiling@gmail.com>
Subject: Re: [PATCH] mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()
Date: Tue, 29 Dec 2015 20:54:23 -0800
Message-ID: <2084563.z85RFGy3ri@diplodocus>
In-Reply-To: <20151230044750.GA18675@sudip-pc>
References: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com> <20151230044750.GA18675@sudip-pc>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, linux-mm@kvack.org, lustre-devel@lists.lustre.org

On Wednesday, December 30, 2015 10:17:50 AM Sudip Mukherjee wrote:
> On Sat, Dec 26, 2015 at 09:12:42PM -0800, Joshua Clayton wrote:
> > running sparse on drivers/staging/lustre results in dozens of warnings:
> > include/linux/gfp.h:281:41: warning:
> > odd constant _Bool cast (400000 becomes 1)
> > 
> > Use "!!" to explicitly convert the result to bool range.
> > ---
> 
> Signed-off-by missing.
> 
> regards
> sudip
Hmm. I must have forgotten the "-s" in git send-email
I'm thinking a patch this size wouldn't qualify for copyright even if an Oracle
Lawyer claimed it.
Nevertheless, all is well. The SOB made it into v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
