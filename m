Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 219466B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 09:15:09 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id c200so30559709wme.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:15:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7si5719606wmg.15.2016.02.10.06.15.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 06:15:07 -0800 (PST)
Subject: Re: mm, compaction: fix build errors with kcompactd
References: <9230470.QhrU67iB7h@wuerfel>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56BB44D4.60004@suse.cz>
Date: Wed, 10 Feb 2016 15:10:28 +0100
MIME-Version: 1.0
In-Reply-To: <9230470.QhrU67iB7h@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/09/2016 03:15 PM, Arnd Bergmann wrote:
> The newly added kcompactd code introduces multiple build errors:
> 
> include/linux/compaction.h:91:12: error: 'kcompactd_run' defined but not used [-Werror=unused-function]
> mm/compaction.c:1953:2: error: implicit declaration of function 'hotcpu_notifier' [-Werror=implicit-function-declaration]
> 
> This marks the new empty wrapper functions as 'inline' to avoid unused-function warnings,
> and includes linux/cpu.h to get the hotcpu_notifier declaration.
> 
> Fixes: 8364acdfa45a ("mm, compaction: introduce kcompactd")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks a lot!
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
