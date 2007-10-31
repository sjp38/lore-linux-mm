Subject: Re: [RFC] oom notifications via /dev/oom_notify
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071031003119.05dc064e@bree.surriel.com>
References: <20071030191827.GB31038@dmt>
	 <1193781568.8904.33.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030171209.0caae1d5@cuia.boston.redhat.com>
	 <472801DC.6050802@us.ibm.com>  <20071031003119.05dc064e@bree.surriel.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 09:01:13 -0800
Message-Id: <1193850073.17412.40.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm <linux-mm@kvack.org>, drepper@redhat.com, Andrew Morton <akpm@linux-foundation.org>, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 00:31 -0400, Rik van Riel wrote:
> On Tue, 30 Oct 2007 21:17:32 -0700
> Badari <pbadari@us.ibm.com> wrote:
> 
> > Rik van Riel wrote:
> > > On Tue, 30 Oct 2007 13:59:28 -0800
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > >
> > >   
> > >> Interesting.. Our database folks wanted some kind of notification
> > >> when there is memory pressure and we are about to kill the biggest
> > >> consumer (in most cases, the most useful application :(). What
> > >> actually they want is a way to get notified, so that they can
> > >> shrink their memory footprint in response. Just notifying before
> > >> OOM may not help, since they don't have time to react. How does
> > >> this notification help ? Are they supposed to monitor swapping
> > >> activity and decide ? 
> > >
> > > Marcelo's code monitors swapping activity and will let userspace
> > > programs (that poll/select the device node) know when they should
> > > shrink their memory footprint.
> > >
> > > This is not "OOM" in the sense of "no more memory or swap", but
> > > in the sense of "we're low on memory - if you don't free something
> > > we'll slow you down by swapping stuff".
> > >
> > >   
> > I think having this kind of OOM notification is a decent start. But
> > any applications that
> > wants to know notifications, would be more interested if kernel is 
> > swapping out any of
> > its data, 
> 
> Well, if the scheme is implemented "right", then what you
> describe will never happen because programs will have freed
> their excess memory already before any swapping happens.

Hmm.. Most cases, application doesn't care about swapping
activity of the kernel - unless its something to do with
one of its own processes/threads. So having notifications
per-process/app/cgroup is what they are looking for.

But again, how they would react to the notification is 
an interesting thing. If they really act nice and free
up stuff they don't need or read more crap and cause
more swapping :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
