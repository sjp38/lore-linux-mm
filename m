Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B07B26B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 15:37:02 -0500 (EST)
Received: by yhoo22 with SMTP id o22so1138355yho.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 12:37:01 -0800 (PST)
Message-ID: <4F3C1771.1050204@gmail.com>
Date: Wed, 15 Feb 2012 15:37:05 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: kill dead prev_priority stubs
References: <20120215192708.31690.2819.stgit@zurg>
In-Reply-To: <20120215192708.31690.2819.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

(2/15/12 2:27 PM), Konstantin Khlebnikov wrote:
> This code was removed in v2.6.35-5854-g25edde0
> ("vmscan: kill prev_priority completely")
>
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   include/linux/memcontrol.h |   15 ---------------
>   1 files changed, 0 insertions(+), 15 deletions(-)

Oh, thank you.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
