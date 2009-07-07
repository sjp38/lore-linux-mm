Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 20E356B0083
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 22:21:58 -0400 (EDT)
Message-ID: <4A52BAD2.6010702@redhat.com>
Date: Mon, 06 Jul 2009 23:02:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] add isolate pages vmstat
References: <20090707090120.1e71a060.minchan.kim@barrios-desktop>	<20090707090509.0C60.A69D9226@jp.fujitsu.com>	<20090707101855.0C63.A69D9226@jp.fujitsu.com> <20090707104806.6706ac4a.minchan.kim@barrios-desktop>
In-Reply-To: <20090707104806.6706ac4a.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> It looks good to me. 
> Thanks for your effort. I added my review sign. :)
> 
> Let remain one side note. 
> This accounting feature results from direct reclaim bomb. 
> If we prevent direct reclaim bomb, I think this feature can be removed. 
> 
> As I know, Rik or Wu is making patch for throttling direct reclaim. 

My plan is to build the patch on top of these patches,
so I'm waiting for them to settle :)

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
