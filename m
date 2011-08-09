Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 066A36B016A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:34:52 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2595127qwa.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 02:34:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC5umygEJy8he1X2Egiuh16HGCC6=Krxv1F3j=bh7xrZmNTHJg@mail.gmail.com>
References: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
	<CAC5umyhWr8t7HyQVEn-W-7HSaeESnTLX8okcQNqPO6mYFuWtUg@mail.gmail.com>
	<CAJ0pr18Mpv7mFHC3NnfqEqtTFd_qgNhH9rZgCENgH0zKmBfFsQ@mail.gmail.com>
	<CAC5umygEJy8he1X2Egiuh16HGCC6=Krxv1F3j=bh7xrZmNTHJg@mail.gmail.com>
Date: Tue, 9 Aug 2011 11:34:51 +0200
Message-ID: <CAJ0pr182aHm7H+s04Pqg5_CxVQLAhGOwLHQ_-aUS7ZgWKSwMxQ@mail.gmail.com>
Subject: Re: [PATCH --mmotm v5 0/3] Make fault injection available for MMC IO
From: Per Forlin <per.forlin@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>, linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org

On 9 August 2011 11:24, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 2011/8/9 Per Forlin <per.forlin@linaro.org>:
>
>> Patch #1 "fault-injection: export fault injection functions" is merged
>
> Maybe you are looking at wrong tree. =A0I can't find it in Linus' tree or
> mmotm patches.
>
Thanks for double checking! I looked at the wrong tree. What a mess I
am creating.
Do you think it would be possible to get only the export
fault-injection patch in 3.1? I know it's not a bugfix so I guess it
wont be accepted.
I'll prepare v6 of this patch-set.

Thanks for your help,
Per

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
