Date: Tue, 27 May 2008 09:57:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/2] lockless get_user_pages
In-Reply-To: <8763t1w1ko.fsf@saeurebad.de>
References: <20080525145227.GC25747@wotan.suse.de> <8763t1w1ko.fsf@saeurebad.de>
Message-Id: <20080527095519.4676.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> > Introduce a new "fast_gup" (for want of a better name right now)
> 
> Perhaps,
> 
>   * get_address_space
>   * get_address_mappings
>   * get_mapped_pages
>   * get_page_mappings
> 
> Or s@get_@ref_@?

Why get_user_pages_lockless() is wrong?
or get_my_pages() is better?
(because this method assume task is current task)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
