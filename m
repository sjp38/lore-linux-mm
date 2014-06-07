Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 038136B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 11:23:51 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so6853130qgz.2
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 08:23:51 -0700 (PDT)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id 110si17270680qgv.9.2014.06.07.08.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Jun 2014 08:23:51 -0700 (PDT)
Received: by mail-qa0-f51.google.com with SMTP id w8so6003446qac.10
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 08:23:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
References: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
Date: Sat, 7 Jun 2014 10:23:50 -0500
Message-ID: <CAMP44s366jWnpyz1+th9+ndrD8XbPgEgOokQPYpBKS=suzeUdA@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhdxzx@sina.com
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, dhillf <dhillf@gmail.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>

On Sat, Jun 7, 2014 at 7:35 AM,  <zhdxzx@sina.com> wrote:

> Would you please try again based only on comment [1](based on v3.15-rc8)?
> thanks
> Hillf
>
> --- a/mm/vmscan.c       Sat Jun  7 18:38:08 2014
> +++ b/mm/vmscan.c       Sat Jun  7 20:08:36 2014
> @@ -1566,7 +1566,7 @@ shrink_inactive_list(unsigned long nr_to
>                  * implies that pages are cycling through the LRU faster than
>                  * they are written so also forcibly stall.
>                  */
> -               if (nr_unqueued_dirty == nr_taken || nr_immediate)
> +               if (nr_immediate)
>                         congestion_wait(BLK_RW_ASYNC, HZ/10);
>         }

That actually seems to work correctly on v3.15-rc8.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
