Date: Wed, 16 Feb 2005 11:02:29 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <20050216100229.GB14545@wotan.suse.de>
References: <20050215074906.01439d4e.pj@sgi.com> <20050215162135.GA22646@lnx-holt.americas.sgi.com> <20050215083529.2f80c294.pj@sgi.com> <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de> <51210000.1108515262@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51210000.1108515262@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Peter Chubb <peterc@gelato.unsw.edu.au>, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm talking about doing it the other way around though - just allocating
> the memory local to the task, not bringing the task to the memory.

That is already how it works. If you take a look at the numastat
statistics, it does also work pretty work pretty well. I don't think
we have a problem in this area.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
