Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED8816B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:55:18 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id u136so723380lff.17
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 02:55:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor139492lfg.42.2018.02.20.02.55.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 02:55:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180220090820.GA153760@rodete-desktop-imager.corp.google.com>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
 <201802201156.4Z60eDwx%fengguang.wu@intel.com> <CAFqt6zagwbvs06yK6KPp1TE5Z-mXzv6Bh2rhFFAyjz3Nh0BXmA@mail.gmail.com>
 <20180220090820.GA153760@rodete-desktop-imager.corp.google.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 20 Feb 2018 16:25:15 +0530
Message-ID: <CAFqt6zZeiU9uMq0kNJRBs_aBTmHvZZkaotJ6GnVOjT6Y3nyS9g@mail.gmail.com>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 2:38 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Souptick,
>
> On Tue, Feb 20, 2018 at 01:09:26PM +0530, Souptick Joarder wrote:
>> On Tue, Feb 20, 2018 at 9:07 AM, kbuild test robot <lkp@intel.com> wrote:
>> > Hi Souptick,
>> >
>> > Thank you for the patch! Perhaps something to improve:
>> >
>> > [auto build test WARNING on mmotm/master]
>> > [also build test WARNING on v4.16-rc2 next-20180219]
>> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>> >
>> > url:    https://github.com/0day-ci/linux/commits/Souptick-Joarder/mm-zsmalloc-Replace-return-type-int-with-bool/20180220-070147
>> > base:   git://git.cmpxchg.org/linux-mmotm.git master
>> >
>> >
>> > coccinelle warnings: (new ones prefixed by >>)
>> >
>> >>> mm/zsmalloc.c:309:65-66: WARNING: return of 0/1 in function 'zs_register_migration' with return type bool
>> >
>> > Please review and possibly fold the followup patch.
>> >
>>
>> OK, I will send the v2.
>
> First of all, thanks for the patch.
>
> Yub, bool could be more appropriate. However, there are lots of other places
> in kernel where use int instead of bool.
> If we fix every such places with each patch, it would be very painful.
> If you believe it's really worth, it would be better to find/fix every
> such places in one patch. But I'm not sure it's worth.
>

Sure, I will create patch series and send it.

> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
