Date: Tue, 5 Feb 2008 15:09:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] badness() dramatically overcounts memory
In-Reply-To: <1202252561.24634.64.camel@dogma.ljc.laika.com>
Message-ID: <alpine.DEB.1.00.0802051507460.18347@chino.kir.corp.google.com>
References: <1202182480.24634.22.camel@dogma.ljc.laika.com>  <47A7E282.1080902@linux.vnet.ibm.com> <1202252561.24634.64.camel@dogma.ljc.laika.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Davis <linux@j-davis.com>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Jeff Davis wrote:

> > The interesting thing is the use of total_vm and not the RSS which is used as
> > the basis by the OOM killer. I need to read/understand the code a bit more.
> 
> RSS makes more sense to me as well.
> 
> To me, it makes no sense to count shared memory, because killing a
> process doesn't free the shared memory.
> 

Andrea Arcangeli has patches pending which change this to the RSS.  
Specifically:

	http://marc.info/?l=linux-mm&m=119977937126925

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
