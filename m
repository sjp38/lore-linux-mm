Date: Mon, 26 Nov 2007 20:18:37 +0900
From: kosaki <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mem notifications v2
In-Reply-To: <20071122173741.GA4990@dmt>
References: <20071122114532.E9E1.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071122173741.GA4990@dmt>
Message-Id: <20071126193254.B6AB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Marcelo

> > Why you use total_swap_pages?
> > Are your intent watching swapon/spwapoff syscall? 
> > 
> > or, s/total_swapcache_pages/nr_swap_pages/ ?
> 
> Oops.
> 
> total_anon_pages() is supposed to return the total number of anonymous pages
> (including swapped out ones), so that should be: 
> 
> #define total_anon_pages() (global_page_state(NR_ANON_PAGES) + \
>                            (total_swap_pages-nr_swap_pages)  - \
>                             total_swapcache_pages

Thank you for your kindness explain.
I understand it.


result of re-reviewed, I have 2 comment. 

1. mem_notify_status turn off in poll is a bit wrong.
   beacause "/dev/mem_notify" watched by multi process is common situation.
2. If it is possible, We may add read method.
   because script language kind to read rather than poll.

especially, I want hear your opinion by comment 2.
I have no confident.


BTW, Do I have any other contribution things for you?


----
kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
