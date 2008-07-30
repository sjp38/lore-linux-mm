Received: by wa-out-1112.google.com with SMTP id m28so98920wag.8
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:33:11 -0700 (PDT)
Message-ID: <2f11576a0807301333s5e1944c5tc997a20a27907980@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:33:10 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] unevictable lru: defer vm event counting
In-Reply-To: <20080730200630.24272.33226.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200630.24272.33226.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2008/7/31 Lee Schermerhorn <lee.schermerhorn@hp.com>:
> Fix to unevictable-lru-infrastructure.patch
>
> NORECL_* events are not defined this early in the series.
> Remove the event counting from this patch and add in with
> unevictable lru statistics [subsequent patch].
>
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Oops, sorry my bad.

   Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
