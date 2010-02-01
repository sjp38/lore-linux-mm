Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C3C2E6B0047
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 11:34:53 -0500 (EST)
Message-ID: <4B670258.6060109@redhat.com>
Date: Mon, 01 Feb 2010 11:33:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] rmap: move exclusively owned pages to own anon_vma
 in do_wp_page
References: <20100128002000.2bf5e365@annuminas.surriel.com>	 <20100128014357.54428c8a@annuminas.surriel.com> <1265037918.20322.32.camel@barrios-desktop>
In-Reply-To: <1265037918.20322.32.camel@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 02/01/2010 10:25 AM, Minchan Kim wrote:

>> Signed-off-by: Rik van Riel<riel@redhat.com>
> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>
>
> Let me have a question for my understanding.
>
> Still, don't we have a probability of O(N) in case of parent's page
> at worst case?

Yes, we do.

However, this can only happen for 1/N pages.

Having O(N) for every page can totally bog down a system,
but only running into that worst case every 1/N pages should
make things run OK again.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
