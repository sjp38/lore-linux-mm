Date: Tue, 15 Jan 2008 11:10:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-Id: <20080115111035.d516639a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008 10:01:21 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	if (pressure) {
> +		nr_wakeup = max_t(int, atomic_read(&nr_watcher_task)>>4, 100);
> +		atomic_long_set(&last_mem_notify, jiffies);
> +		wake_up_locked_nr(&mem_wait, nr_wakeup);
> +	}
What is this for ? and Why ?
Are there too many waiters ?

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
