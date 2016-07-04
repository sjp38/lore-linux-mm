Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6720F6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 04:44:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so380159255pfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 01:44:01 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f15si3099678pap.97.2016.07.04.01.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 01:44:00 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so15882854pfb.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 01:44:00 -0700 (PDT)
Date: Mon, 4 Jul 2016 17:43:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Message-ID: <20160704084347.GG898@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
[..]
> -static void zs_unregister_cpu_notifier(void)
> +static void __exit zs_unregister_cpu_notifier(void)
>  {

this __exit symbol is called from `__init zs_init()' and thus is
free to crash.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
