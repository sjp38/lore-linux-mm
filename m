Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id BED2D6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 14:07:19 -0400 (EDT)
Message-ID: <4FA2C946.60006@redhat.com>
Date: Thu, 03 May 2012 14:07:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into
 per user_struct spinlock
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
In-Reply-To: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rajman mekaco <rajman.mekaco@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/03/2012 01:34 PM, rajman mekaco wrote:
> The user_shm_lock and user_shm_unlock functions use a single global
> spinlock for protecting the user->locked_shm.
>
> This is an overhead for multiple CPUs calling this code even if they
> are having different user_struct.
>
> Remove the global shmlock_user_lock and introduce and use a new
> spinlock inside of the user_struct structure.
>
> Signed-off-by: rajman mekaco<rajman.mekaco@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
