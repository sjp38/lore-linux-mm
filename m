Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BE6696B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 19:13:21 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id e128so860328pfe.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:13:21 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id r18si6028372pfi.140.2016.04.11.16.13.20
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 16:13:20 -0700 (PDT)
Date: Tue, 12 Apr 2016 08:13:19 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: Re: [PATCH] memory failure: replace 'MCE' with 'Memory failure'
Message-ID: <20160411231316.GA13627@www9186uo.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <1460122875-4635-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Apr 08, 2016 at 09:41:15PM +0800, Chen Yucong wrote:
> HWPoison was specific to some particular x86 platforms.
> And it is often seen as high level machine check handler.
> And therefore, 'MCE' is used for the format prefix of
> printk(). However, 'PowerNV' has also used HWPoison for
> handling memory errors[1], so 'MCE' is no longer suitable
> to memory_failure.c.
> 
> Additionally, 'MCE' and 'Memory failure' have different
> context. The former belongs to exception context and the
> latter belongs to process context. Furthermore, HWPoison
> can also be used for off-lining those sub-health pages
> that do not trigger any machine check exception.
> 
> This patch aims to replace 'MCE' with a more appropriate prefix.
> 
> [1] commit 75eb3d9b60c2 ("powerpc/powernv: Get FSP memory errors
> and plumb into memory poison infrastructure.")
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

Fair enough, thank you.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
