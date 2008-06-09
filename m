Date: Mon, 09 Jun 2008 09:37:22 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] introduce sysctl of throttle
In-Reply-To: <20080608130935.ea7076fc.akpm@linux-foundation.org>
References: <20080605021505.694195095@jp.fujitsu.com> <20080608130935.ea7076fc.akpm@linux-foundation.org>
Message-Id: <20080609093617.7865.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > +int vm_max_nr_task_per_zone __read_mostly
> > +       = CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE;
> 
> It would be nice if we could remove
> CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE altogether.  Its a pretty obscure
> thing and we haven't provided people wait any information which would
> permit them to tune it anwyay.
> 
> In which case this patch should be folded into [4/5].

Sure.
I'll remove CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE Kconfig.

Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
