Received: by yw-out-1718.google.com with SMTP id 5so120341ywm.26
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:40:56 -0700 (PDT)
Message-ID: <2f11576a0807301340s1289f93al80202135261c7f6b@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:40:55 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] mlocked-pages: add event counting with statistics
In-Reply-To: <20080730200649.24272.58778.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200649.24272.58778.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

> +               } else {
> +                       /*
> +                        * We lost the race.  let try_to_unmap() deal
> +                        * with it.  At least we get the page state and
> +                        * mlock stats right.  However, page is still on
> +                        * the noreclaim list.  We'll fix that up when
> +                        * the page is eventually freed or we scan the
> +                        * noreclaim list.

                               unevictable list?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
