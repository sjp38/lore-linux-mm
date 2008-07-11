Date: Fri, 11 Jul 2008 23:11:38 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 0/5] kmemtrace RFC patch series
Message-ID: <20080711231138.5d3443b8@linux360.ro>
In-Reply-To: <20080711153841.GA14359@Krystal>
References: <20080710210543.1945415d@linux360.ro>
	<20080711153841.GA14359@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 11:38:41 -0400
Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> Hi Eduard,
> 
> Did you have a look at the new tracepoints infrastructure ? I think it
> could simplify your patchset a _lot_ !

Hi,

Yes, I did. In fact, I asked you to keep me Cc-ed, which you did. 
 
> Basically, it removes the format string from markers and allows to
> pass complex structure pointers as arguments. It aims at simplifying
> the life of in-kernel tracers which would want to use the facility.
> Turning a marker implementation to tracepoints is really
> straightforward, for an example see :
> 
> http://lkml.org/lkml/2008/7/9/569
> 
> For the tracepoints patchset :
> 
> http://lkml.org/lkml/2008/7/9/199
> 
> I think much of include/linux/kmemtrace.h, which is really just
> wrappers around marker code, could then go away.

Basically, I want just as much to get rid of markers. I'm just waiting
for tracepoints to get closer to mainline.

	Cheers,
	Eduard

> Regards,
> 
> Mathieu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
