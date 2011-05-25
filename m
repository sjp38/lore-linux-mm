Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7EBC46B0022
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:27:34 -0400 (EDT)
Message-ID: <4DDCF5B2.3060209@redhat.com>
Date: Wed, 25 May 2011 08:27:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] swap-token: makes global variables to function local
References: <4DD480DD.2040307@jp.fujitsu.com>	<4DD481A7.3050108@jp.fujitsu.com> <20110520123004.e81c932e.akpm@linux-foundation.org> <4DDB1388.2080102@jp.fujitsu.com> <4DDC73B7.1050409@jp.fujitsu.com>
In-Reply-To: <4DDC73B7.1050409@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com

On 05/24/2011 11:12 PM, KOSAKI Motohiro wrote:
> global_faults and last_aging are only used in grab_swap_token().
> Then, they can be moved into grab_swap_token().
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
