Date: Wed, 16 Feb 2005 07:21:39 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <232990000.1108567298@[10.10.2.4]>
In-Reply-To: <20050216100229.GB14545@wotan.suse.de>
References: <20050215074906.01439d4e.pj@sgi.com> <20050215162135.GA22646@lnx-holt.americas.sgi.com> <20050215083529.2f80c294.pj@sgi.com> <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de> <51210000.1108515262@flay> <20050216100229.GB14545@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Peter Chubb <peterc@gelato.unsw.edu.au>, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Andi Kleen <ak@suse.de> wrote (on Wednesday, February 16, 2005 11:02:29 +0100):

>> I'm talking about doing it the other way around though - just allocating
>> the memory local to the task, not bringing the task to the memory.
> 
> That is already how it works. If you take a look at the numastat
> statistics, it does also work pretty work pretty well. I don't think
> we have a problem in this area.

>From reading the code (not actual experiments, yet), it seems like we won't
even wake up the local kswapd until all the nodes are full. And all of the
most recently allocated stuff will end up remote, which seems like a poor
choice.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
