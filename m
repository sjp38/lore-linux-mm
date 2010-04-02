Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BE3E66B01F0
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:33:01 -0400 (EDT)
Date: Fri, 2 Apr 2010 20:30:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH -mm 0/4] oom: linux has threads
Message-ID: <20100402183057.GA31723@redhat.com>
References: <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402111406.GA4432@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/02, Oleg Nesterov wrote:
>
> Once again:
>
> 	void *memory_hog_thread(void *arg)
> 	{
> 		for (;;)
> 			malloc(A_LOT);
> 	}
>
> 	int main(void)
> 	{
> 		pthread_create(memory_hog_thread, ...);
> 		syscall(__NR_exit, 0);
> 	}
>
> Now, even if we fix PF_EXITING check, select_bad_process() will always
> ignore this process. The group leader has ->mm == NULL.

So. Please see the COMPLETELY UNTESTED patches I am sending. They need
your review, or feel free to redo these fixes. 4/4 is a bit off-topic.

Also, please note the "This patch is not enough" comment in 3/4.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
