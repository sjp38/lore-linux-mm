Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A49736B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 05:21:43 -0400 (EDT)
Received: by mail-ia0-f176.google.com with SMTP id i18so2719960iac.35
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:21:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1362896833-21104-13-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
	<1362896833-21104-13-git-send-email-jiang.liu@huawei.com>
Date: Sun, 10 Mar 2013 10:21:42 +0100
Message-ID: <CAMuHMdWSP-Pb09nAcoMPdEA9mHA=FqjPGAvts9B20q7-iqLckA@mail.gmail.com>
Subject: Re: [PATCH v2, part1 12/29] mm/m68k: use common help functions to
 free reserved pages
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 10, 2013 at 7:26 AM, Jiang Liu <liuj97@gmail.com> wrote:
> Use common help functions to free reserved pages.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>

24 bytes of text size saved!

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
