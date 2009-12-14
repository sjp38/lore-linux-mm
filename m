Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B7F16B0047
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:34:38 -0500 (EST)
Message-ID: <4B264CF8.30409@redhat.com>
Date: Mon, 14 Dec 2009 09:34:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Mark sleep_on as deprecated
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com> <20091214212351.BBB4.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091214212351.BBB4.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 07:24 AM, KOSAKI Motohiro wrote:
>
>
> sleep_on() function is SMP and/or kernel preemption unsafe. we shouldn't
> use it on new code.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
