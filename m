Date: Wed, 6 Feb 2002 10:03:44 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: .Help with measuring working-set
Message-ID: <20020206100344.A28700@wotan.suse.de>
References: <3C5F418C.6030808@netscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3C5F418C.6030808@netscape.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suresh Duddi <dp@netscape.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2002 at 06:21:00PM -0800, Suresh Duddi wrote:
> hi, I am developer of Mozilla (open source web browser from mozilla.org) 
> We are trying to make footprint improvements to the browser and have 
> settled on minimizing working set and max-vm-usage as our goals.
> 
> http://www.mozilla.org/projects/footprint/footprint-guide.html
> 
> One thing we are struggling with is measurement of working set of app 
> during a time interval.

The only metric the kernel supports for the working set currently is a 
single RSS integer telling you have many pages are currently mapped into
a process. There may be more pages from your process unmapped in RAM, 
but being unmapped is usually the first step to swap the page out or 
throw it away. 

> Any pointers ? Are the metrics the best ones to measure and optimize ?

I guess you would prefer to know which pages are mapped at a given
point. This would require some custom patching to add a trace facility
for that. Shouldn't be that hard to implement, but I don't know of a 
ready patch.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
