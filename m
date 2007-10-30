Subject: Re: [RFC] oom notifications via /dev/oom_notify
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071030191827.GB31038@dmt>
References: <20071030191827.GB31038@dmt>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 13:59:28 -0800
Message-Id: <1193781568.8904.33.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm <linux-mm@kvack.org>, drepper@redhat.com, riel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-30 at 15:18 -0400, Marcelo Tosatti wrote:
> Hi,
> 
> Following patch creates a /dev/oom_notify device which applications can
> select()/poll() to get informed of memory pressure.
> 
> The basic idea here is that applications can be part of the memory
> reclaim process. The notification is loosely defined as "please free
> some small percentage of your memory".
> 
> There is no easy way of finding whether the system is approaching a
> state where swapping is required in the reclaim paths, so a defensive
> approach is taken by using a timer with 1Hz frequency which verifies
> whether swapping has occurred.
> 
> For scenarios which require a "severe pressure notification" (please
> read Nokia's implementation at http://www.linuxjournal.com/article/8502 for
> more details), I believe the best solution is to create a separate
> /dev/oom_notify_critical device to avoid complication of the main device
> code paths. Take into account that such notification needs careful
> synchronization with the OOM killer.
> 
> Comments please...

Interesting.. Our database folks wanted some kind of notification when
there is memory pressure and we are about to kill the biggest consumer
(in most cases, the most useful application :(). What actually they
want is a way to get notified, so that they can shrink their memory
footprint in response. Just notifying before OOM may not help, since
they don't have time to react. How does this notification help ? Are
they supposed to monitor swapping activity and decide ?

Thanks,
Badari



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
