Date: Sun, 8 Jun 2008 13:10:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] introduce sysctl of throttle
Message-Id: <20080608131013.b178084b.akpm@linux-foundation.org>
In-Reply-To: <20080605021505.694195095@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
	<20080605021505.694195095@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Jun 2008 11:12:16 +0900 kosaki.motohiro@jp.fujitsu.com wrote:

>  # echo 5 > /proc/sys/vm/max_nr_task_per_zone

Please document /proc/sys/vm tunables in Documentation/filesystems/proc.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
