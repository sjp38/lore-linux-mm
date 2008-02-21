Received: by py-out-1112.google.com with SMTP id f47so13451pye.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 04:41:15 -0800 (PST)
Message-ID: <2f11576a0802210441n5912ddcfne45138c52e77c159@mail.gmail.com>
Date: Thu, 21 Feb 2008 21:41:15 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <44c63dc40802210429y24757a34p2cc8093a2db6181a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220181447.6444.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802200149r6b03d970g2fbde74b85ad5443@mail.gmail.com>
	 <20080220185648.6447.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802210138s100e921ekde01b30bae13beb1@mail.gmail.com>
	 <2f11576a0802210255k1e3acad7n87814e916fd24509@mail.gmail.com>
	 <44c63dc40802210429y24757a34p2cc8093a2db6181a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  >  please repost question with change subject.
>  >  i don't know reason of vanilla kernel behavior, sorry.
>
>  Normally, embedded linux have only one zone(DMA).
>
>  If your patch isn't applied, several processes can reclaim memory in parallel.
>  then, DMA zone's pages_scanned is suddenly increased largely. Because
>  embedded linux have no swap device,  kernel can't stop to scan lru
>  list until meeting page cache page. so if zone->pages_scanned is
>  greater six time than lru list pages, kernel make the zone with
>  unreclaimable state, As a result, OOM will kill it, too.

sorry, my last mail is easy confusious.
if you want discuss vanilla kernel bug, you shold post mail by another thread.
if not, your mail is only readed by few people.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
