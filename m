Date: Wed, 31 Oct 2007 00:31:19 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071031003119.05dc064e@bree.surriel.com>
In-Reply-To: <472801DC.6050802@us.ibm.com>
References: <20071030191827.GB31038@dmt>
	<1193781568.8904.33.camel@dyn9047017100.beaverton.ibm.com>
	<20071030171209.0caae1d5@cuia.boston.redhat.com>
	<472801DC.6050802@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari <pbadari@us.ibm.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm <linux-mm@kvack.org>, drepper@redhat.com, Andrew Morton <akpm@linux-foundation.org>, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007 21:17:32 -0700
Badari <pbadari@us.ibm.com> wrote:

> Rik van Riel wrote:
> > On Tue, 30 Oct 2007 13:59:28 -0800
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> >   
> >> Interesting.. Our database folks wanted some kind of notification
> >> when there is memory pressure and we are about to kill the biggest
> >> consumer (in most cases, the most useful application :(). What
> >> actually they want is a way to get notified, so that they can
> >> shrink their memory footprint in response. Just notifying before
> >> OOM may not help, since they don't have time to react. How does
> >> this notification help ? Are they supposed to monitor swapping
> >> activity and decide ? 
> >
> > Marcelo's code monitors swapping activity and will let userspace
> > programs (that poll/select the device node) know when they should
> > shrink their memory footprint.
> >
> > This is not "OOM" in the sense of "no more memory or swap", but
> > in the sense of "we're low on memory - if you don't free something
> > we'll slow you down by swapping stuff".
> >
> >   
> I think having this kind of OOM notification is a decent start. But
> any applications that
> wants to know notifications, would be more interested if kernel is 
> swapping out any of
> its data, 

Well, if the scheme is implemented "right", then what you
describe will never happen because programs will have freed
their excess memory already before any swapping happens.

Tweaking the wakeup selection by NUMA node probably makes
sense as a future enhancement, though.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
