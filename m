Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CC52F6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 20:51:08 -0400 (EDT)
Received: by vwm42 with SMTP id 42so4011279vwm.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 17:51:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
References: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
Date: Tue, 9 Aug 2011 09:51:06 +0900
Message-ID: <CAC5umyhWr8t7HyQVEn-W-7HSaeESnTLX8okcQNqPO6mYFuWtUg@mail.gmail.com>
Subject: Re: [PATCH --mmotm v5 0/3] Make fault injection available for MMC IO
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>, linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org

All three patches look good.
Acked-by: Akinobu Mita <akinobu.mita@gmail.com>

2011/8/9 Per Forlin <per.forlin@linaro.org>:
> This patchset is sent to the mm-tree because it depends on Akinobu's patch
> "fault-injection: add ability to export fault_attr in..."

That patch has already been merged in mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
