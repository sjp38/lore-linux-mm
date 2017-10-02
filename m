Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 749C86B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 08:06:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m198so4936622oig.19
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 05:06:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w138sor4533809iof.78.2017.10.02.05.06.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 05:06:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002084131.GA24414@amd>
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd> <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com> <20171002084131.GA24414@amd>
From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 2 Oct 2017 14:06:03 +0200
Message-ID: <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Adrian Hunter <adrian.hunter@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On Mon, Oct 2, 2017 at 10:41 AM, Pavel Machek <pavel@ucw.cz> wrote:

>> Bounce buffers are being removed from v4.15

As Adrian states, this would make any last bugs go away. I would
even consider putting this patch this into fixes if it solves the problem.

> although you may experience
>> performance regression with that:
>>
>>       https://marc.info/?l=linux-mmc&m=150589778700551
>
> Hmm. The performance of this is already pretty bad, I really hope it
> does not get any worse.

Did you use bounce buffers? Those were improving performance on
some laptops with TI or Ricoh host controllers and nothing else was
ever really using it (as can be seen from the commit).

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
