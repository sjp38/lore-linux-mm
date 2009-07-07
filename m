Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9D4D76B0082
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 21:50:18 -0400 (EDT)
Received: by pzk41 with SMTP id 41so3950345pzk.12
        for <linux-mm@kvack.org>; Mon, 06 Jul 2009 19:31:24 -0700 (PDT)
Date: Tue, 7 Jul 2009 11:31:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
Message-Id: <20090707113113.84cf1347.minchan.kim@barrios-desktop>
In-Reply-To: <20090707111030.0C69.A69D9226@jp.fujitsu.com>
References: <20090707101855.0C63.A69D9226@jp.fujitsu.com>
	<20090707104806.6706ac4a.minchan.kim@barrios-desktop>
	<20090707111030.0C69.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue,  7 Jul 2009 11:12:33 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > It looks good to me. 
> > Thanks for your effort. I added my review sign. :)
> > 
> > Let remain one side note. 
> > This accounting feature results from direct reclaim bomb. 
> > If we prevent direct reclaim bomb, I think this feature can be removed. 
> 
> Hmmm. I disagree.
> isolated pages can become more than >1GB on server systems.
> Who want >1GB unaccountable memory?

I am okay if it happens without reclaim bomb on server system which 
have a lot of memory as you said.  

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
