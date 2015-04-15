Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 51E2D6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 11:07:45 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so87854882qkh.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:07:45 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a63si4867742qga.120.2015.04.15.08.07.21
        for <linux-mm@kvack.org>;
        Wed, 15 Apr 2015 08:07:21 -0700 (PDT)
Date: Wed, 15 Apr 2015 16:07:12 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: record accurate early log buffer count and
 report when exceeded
Message-ID: <20150415150712.GD22741@localhost>
References: <1429098292-76415-1-git-send-email-morgan.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429098292-76415-1-git-send-email-morgan.wang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Kai <morgan.wang@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

BTW, you misspelled the LKML address (I fixed it: s/\.or/\.org/)

On Wed, Apr 15, 2015 at 12:44:52PM +0100, Wang Kai wrote:
> In log_early function, crt_early_log should also count once when
> 'crt_early_log >= ARRAY_SIZE(early_log)'. Otherwise the reported
> count from kmemleak_init is one less than 'actual number'.
> 
> Then, in kmemleak_init, if early_log buffer size equal actual
> number, kmemleak will init sucessful, so change warning condition
> to 'crt_early_log > ARRAY_SIZE(early_log)'.
> 
> Signed-off-by: Wang Kai <morgan.wang@huawei.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
