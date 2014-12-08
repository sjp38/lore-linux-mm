Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 120C26B0038
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 19:07:34 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4100368pac.11
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 16:07:33 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id of5si27998596pbb.197.2014.12.07.16.07.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 16:07:32 -0800 (PST)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1FFA63EE1AB
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 09:07:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 1D152AC0475
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 09:07:29 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEFB3E08006
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 09:07:28 +0900 (JST)
Message-ID: <5484EBA5.8050302@jp.fujitsu.com>
Date: Mon, 8 Dec 2014 09:07:01 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Drivers: hv: hv_balloon: Fix a deadlock in the hot-add
 path.
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
In-Reply-To: <1417826471-21131-1-git-send-email-kys@microsoft.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org

(2014/12/06 9:41), K. Y. Srinivasan wrote:
> Fix a deadlock in the hot-add path in the Hyper-V balloon driver.
> 

> K. Y. Srinivasan (2):
>    Drivers: base: core: Export functions to lock/unlock device hotplug
>      lock
>    Drivers: hv: balloon: Fix the deadlock issue in the memory hot-add
>      code

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasauaki Ishimatsu

> 
>   drivers/base/core.c     |    2 ++
>   drivers/hv/hv_balloon.c |    4 ++++
>   2 files changed, 6 insertions(+), 0 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
