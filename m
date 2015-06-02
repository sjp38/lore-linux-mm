Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4C32A900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 17:09:58 -0400 (EDT)
Received: by igblz2 with SMTP id lz2so21565798igb.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:09:58 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0149.hostedemail.com. [216.40.44.149])
        by mx.google.com with ESMTP id y9si15146600icn.43.2015.06.02.14.09.57
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 14:09:57 -0700 (PDT)
Message-ID: <1433279395.4861.100.camel@perches.com>
Subject: Re: [PATCH] MAINTAINERS: add zpool
From: Joe Perches <joe@perches.com>
Date: Tue, 02 Jun 2015 14:09:55 -0700
In-Reply-To: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
References: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2015-06-02 at 12:56 -0400, Dan Streetman wrote:
> Add entry for zpool to MAINTAINERS file.
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -11056,6 +11056,13 @@ L:	zd1211-devs@lists.sourceforge.net (subscribers-only)
>  S:	Maintained
>  F:	drivers/net/wireless/zd1211rw/
>  
> +ZPOOL COMPRESSED PAGE STORAGE API
> +M:	Dan Streetman <ddstreet@ieee.org>
> +L:	linux-mm@kvack.org
> +S:	Maintained
> +F:	mm/zpool.c
> +F:	include/linux/zpool.h

If zpool.h is only included from files in mm/,
maybe zpool.h should be moved to mm/ ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
