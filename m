Date: Wed, 16 Feb 2005 17:08:33 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <20050216160833.GB6604@wotan.suse.de>
References: <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de> <51210000.1108515262@flay> <20050216100229.GB14545@wotan.suse.de> <232990000.1108567298@[10.10.2.4]> <20050216074923.63cf1b6b.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050216074923.63cf1b6b.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, ak@suse.de, raybry@sgi.com, peterc@gelato.unsw.edu.au, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 16, 2005 at 07:49:23AM -0800, Paul Jackson wrote:
> Martin wrote:
> > From reading the code (not actual experiments, yet), it seems like we won't
> > even wake up the local kswapd until all the nodes are full. And ...
> 
> Martin - is there a Cliff Notes summary you could provide of this
> subthread you and Andi are having?  I got lost somewhere along the way.

I didn't really have much thread, but as far as I understood it
Martin just wants kswapd to be a bit more aggressive in making sure
all nodes always have local memory to allocate from.

I don't see it as a pressing problem right now, but it may help
for some memory intensive workloads a bit (see numastat numa_miss output for
various nodes on how often a "wrong node" fallback happens) 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
