Received: by wa-out-1112.google.com with SMTP id m28so99188wag.8
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:34:25 -0700 (PDT)
Message-ID: <2f11576a0807301334u55aebc98k71acf19d107504b1@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:34:24 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] unevictable lru: add event counting with statistics
In-Reply-To: <20080730200636.24272.54065.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200636.24272.54065.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

> Fix to unevictable-lru-page-statistics.patch
>
> Add unevictable lru infrastructure vm events to the statistics patch.
> Rename the "NORECL_" and "noreclaim_" symbols and text strings to
> "UNEVICTABLE_" and "unevictable_", respectively.
>
> Currently, both the infrastructure and the mlocked pages event are
> added by a single patch later in the series.  This makes it difficult
> to add or rework the incremental patches.  The events actually "belong"
> with the stats, so pull them up to here.
>
> Also, restore the event counting to putback_lru_page().  This was removed
> from previous patch in series where it was "misplaced".  The actual events
> weren't defined that early.

okey.
   Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
