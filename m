Date: Mon, 09 Jun 2008 09:34:01 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] introduce sysctl of throttle
In-Reply-To: <20080608131013.b178084b.akpm@linux-foundation.org>
References: <20080605021505.694195095@jp.fujitsu.com> <20080608131013.b178084b.akpm@linux-foundation.org>
Message-Id: <20080609093319.7862.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> >  # echo 5 > /proc/sys/vm/max_nr_task_per_zone
> 
> Please document /proc/sys/vm tunables in Documentation/filesystems/proc.txt

Oh, makes sense.
Thank you good advice!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
