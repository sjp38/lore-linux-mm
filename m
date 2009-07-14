Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A13A46B005C
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 04:52:06 -0400 (EDT)
Date: Tue, 14 Jul 2009 11:21:59 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090714112159.ae8b154c.skraw@ithnet.com>
In-Reply-To: <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
	<4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
	<alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 22:53:29 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 13 Jul 2009, Jesse Brandeburg wrote:
> > Try increasing /proc/sys/vm/min_free_kbytes
> > 
> 
> That won't do anything but cause the failure to happen earlier because 
> GFP_HIGH will be restricted to even less ZONE_NORMAL memory.
> 
> This is a duplicate of http://bugzilla.kernel.org/show_bug.cgi?id=13648 
> which also only affects e1000.
> 
> Stephan, perhaps you can try with a CONFIG_SLUB kernel and enable both 
> CONFIG_SLUB_DEBUG and CONFIG_SLUB_DEBUG_ON?  If that doesn't reveal any 
> additional information, this sounds like a candidate for kmemleak.

I just enabled that, fortunately we can play some with this box ;-)
I will inform you tommorrow what happened.
Thanks, stay tuned.

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
