Date: Wed, 16 Feb 2005 07:49:23 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
 sys_page_migrate
Message-Id: <20050216074923.63cf1b6b.pj@sgi.com>
In-Reply-To: <232990000.1108567298@[10.10.2.4]>
References: <20050215074906.01439d4e.pj@sgi.com>
	<20050215162135.GA22646@lnx-holt.americas.sgi.com>
	<20050215083529.2f80c294.pj@sgi.com>
	<20050215185943.GA24401@lnx-holt.americas.sgi.com>
	<16914.28795.316835.291470@wombat.chubb.wattle.id.au>
	<421283E6.9030707@sgi.com>
	<31650000.1108511464@flay>
	<421295FB.3050005@sgi.com>
	<20050216004401.GB8237@wotan.suse.de>
	<51210000.1108515262@flay>
	<20050216100229.GB14545@wotan.suse.de>
	<232990000.1108567298@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: ak@suse.de, raybry@sgi.com, peterc@gelato.unsw.edu.au, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin wrote:
> From reading the code (not actual experiments, yet), it seems like we won't
> even wake up the local kswapd until all the nodes are full. And ...

Martin - is there a Cliff Notes summary you could provide of this
subthread you and Andi are having?  I got lost somewhere along the way.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
