Date: Wed, 16 Feb 2005 01:44:01 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <20050216004401.GB8237@wotan.suse.de>
References: <1108407043.6154.49.camel@localhost> <20050214220148.GA11832@lnx-holt.americas.sgi.com> <20050215074906.01439d4e.pj@sgi.com> <20050215162135.GA22646@lnx-holt.americas.sgi.com> <20050215083529.2f80c294.pj@sgi.com> <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421295FB.3050005@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Peter Chubb <peterc@gelato.unsw.edu.au>, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> SGI had code in IRIX to do that kind of thing (automatically move a page to
> the node where most of the references were coming from).  Never worked very 
> well, I have been told.   So our bias is away from such "automatic" page
> migration schemes and toward "manual" methods driven either by a user
> command or a user-level program such as a batch scheduler.

I tried something similar too (scheduling a task to the node with most of 
its memory) and it also never worked very well.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
