Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DB7176B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 05:09:19 -0500 (EST)
Received: by iacb35 with SMTP id b35so7964791iac.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 02:09:19 -0800 (PST)
Date: Mon, 9 Jan 2012 02:09:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195521.GA19181@suse.de>
 <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Mon, 9 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> 1.1. Pekka Enberg
> > However, from VM point of view, both have the exact same 
> > functionality: detect when we reach low memory condition
> > (for some configurable threshold) and notify userspace or kernel 
> > subsystem about it.
> 
> Well, I cannot say that SIGKILL is a notification. From kernel side 
> maybe. But Android OOM uses different memory tracking rules. From my 
> opinion OOM killer should be as reliable as default is but functionality 
> Android OOM killer does should be done in user space by some "smart 
> killer" which closes application correct way (save data, notify user 
> etc.). It heavily depends from product design.
> 

I'm not sure why you need to detect low memory thresholds if you're not 
interested in using the memory controller, why not just use the oom killer 
delay that I suggested earlier and allow userspace to respond to 
conditions when you are known to failed reclaim and require that something 
be killed?  Userspace should be able to make sane decisions or trigger 
external knobs to be able to free memory much better than having the 
kernel handling signals or notification to individual applications.

> 1.7. David Rientjes
> > This is just a side-note but as this information is meant to be consumed by userspace you have the option of hooking
> > into the mm_page_alloc tracepoint. You get the same information about how many pages are allocated or freed. I accept
> > that it will probably be a bit slower but on the plus side it'll be backwards compatible and you don't need a kernel
> > patch for it.
> 

I didn't write that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
