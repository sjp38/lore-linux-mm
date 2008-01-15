Date: Tue, 15 Jan 2008 13:42:50 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-ID: <20080115134250.01efa07d@lxorguk.ukuu.org.uk>
In-Reply-To: <20080115120552.GA25009@dmt>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115104619.10dab6de@lxorguk.ukuu.org.uk>
	<20080115195022.11A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115112027.6120915b@lxorguk.ukuu.org.uk>
	<20080115120552.GA25009@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Tasks are added to the end of waitqueue->task_list through
> add_wait_queue_exclusive, and waken up from the start of the list. So
> I don't think that can happen (its FIFO).

Agreed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
