Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 673CE6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 17:52:28 -0500 (EST)
Received: by ywh3 with SMTP id 3so3668549ywh.22
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 14:52:26 -0800 (PST)
Date: Tue, 15 Dec 2009 07:46:50 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/8] Don't use sleep_on()
Message-Id: <20091215074650.8fc2e6b5.minchan.kim@barrios-desktop>
In-Reply-To: <20091214212449.BBB7.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214212449.BBB7.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:29:28 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> sleep_on() is SMP and/or kernel preemption unsafe. This patch
> replace it with safe code.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviwed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
