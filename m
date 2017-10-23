Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B526B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:16:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y15so16840163ita.22
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:16:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j126sor2705732itb.105.2017.10.23.05.16.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 05:16:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171023093109.GI32228@amd>
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd> <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com> <20171002084131.GA24414@amd>
 <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
 <20171002130353.GA25433@amd> <184b3552-851c-7015-dd80-76f6eebc33cc@intel.com> <20171023093109.GI32228@amd>
From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 23 Oct 2017 14:16:40 +0200
Message-ID: <CACRpkdaa6qq91+dQ43EZDvDefbM3tjwLX5e+nNZouwXM0xJ=4w@mail.gmail.com>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Adrian Hunter <adrian.hunter@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On Mon, Oct 23, 2017 at 11:31 AM, Pavel Machek <pavel@ucw.cz> wrote:

>> > Thinkpad X220... how do I tell if I was using them? I believe so,
>> > because I uncovered bug in them before.
>>
>> You are certainly using bounce buffers.  What does lspci -knn show?
>
> Here is the output:
> 0d:00.0 System peripheral [0880]: Ricoh Co Ltd PCIe SDXC/MMC Host Controller [1180:e823] (rev 07)
>         Subsystem: Lenovo Device [17aa:21da]
>         Kernel driver in use: sdhci-pci

So that is a Ricoh driver, one of the few that was supposed to benefit
from bounce buffers.

Except that if you actually turned it on:
> [10994.302196] kworker/2:1: page allocation failure: order:4,
so it doesn't have enough memory to use these bounce buffers
anyway.

I'm now feel it was the right thing to delete them.

I assume the problem doesn't appear in later -rc:s am I right?

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
