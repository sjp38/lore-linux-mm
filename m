Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4A06B016B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:17:09 -0400 (EDT)
Received: by vwm42 with SMTP id 42so4348250vwm.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 03:17:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ0pr182aHm7H+s04Pqg5_CxVQLAhGOwLHQ_-aUS7ZgWKSwMxQ@mail.gmail.com>
References: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
	<CAC5umyhWr8t7HyQVEn-W-7HSaeESnTLX8okcQNqPO6mYFuWtUg@mail.gmail.com>
	<CAJ0pr18Mpv7mFHC3NnfqEqtTFd_qgNhH9rZgCENgH0zKmBfFsQ@mail.gmail.com>
	<CAC5umygEJy8he1X2Egiuh16HGCC6=Krxv1F3j=bh7xrZmNTHJg@mail.gmail.com>
	<CAJ0pr182aHm7H+s04Pqg5_CxVQLAhGOwLHQ_-aUS7ZgWKSwMxQ@mail.gmail.com>
Date: Tue, 9 Aug 2011 19:17:05 +0900
Message-ID: <CAC5umyhyRCU9mNCz9Q2Ly1f3+UEv+EOGicd735QXjpKUAvzDzw@mail.gmail.com>
Subject: Re: [PATCH --mmotm v5 0/3] Make fault injection available for MMC IO
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>, linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org

2011/8/9 Per Forlin <per.forlin@linaro.org>:

> Do you think it would be possible to get only the export
> fault-injection patch in 3.1? I know it's not a bugfix so I guess it
> wont be accepted.

No modules except mmc plan to use those symbols.  So I think there is
no reason to merge them separately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
