Date: Tue, 15 Jan 2008 13:42:09 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-ID: <20080115134209.7b3c2f7e@lxorguk.ukuu.org.uk>
In-Reply-To: <20080115202711.11A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115195022.11A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115112027.6120915b@lxorguk.ukuu.org.uk>
	<20080115202711.11A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> current wake up order is simply FIFO by poll(2) called.
> because the VM cannot know how much amount each process can do in free.
> the process rss and freeable memory is not proportional.

Ok this makes sense.
> 
> thus I adopt wake up one after another until restoration memory shortage.
> 
> 
> > It also appears there is no way to wait for memory shortages (processes
> > that can free memory easily) only for memory to start appearing.
> 
> poll() with never timeout don't fill your requirement?
> to be honest, maybe I don't understand your afraid yet. sorry.

My misunderstanding. There is in fact no way to wait for memory to become
available. The poll() method you provide works nicely waiting for
shortages and responding to them by freeing memory.

It would be interesting to add FASYNC support to this. Some users have
asked for a signal when memory shortage occurs (as IBM AIX provides
this). FASYNC support would allow a SIGIO to be delivered from this
device when memory shortages occurred. Poll as you have implemented is of
course the easier way for a program to monitor memory and a better
interface.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
