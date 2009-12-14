Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A57556B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 17:49:58 -0500 (EST)
Received: by ywh3 with SMTP id 3so3666219ywh.22
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 14:49:52 -0800 (PST)
Date: Tue, 15 Dec 2009 07:44:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/8] Mark sleep_on as deprecated
Message-Id: <20091215074423.0dd2911c.minchan.kim@barrios-desktop>
In-Reply-To: <20091214212351.BBB4.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214212351.BBB4.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:24:40 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> 
> sleep_on() function is SMP and/or kernel preemption unsafe. we shouldn't
> use it on new code.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

We would be better to remove this function.
But it's enough to that in this patch series.  
We have to remove sleep_on with another patch series. 

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
