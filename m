Date: Fri, 20 Feb 2004 14:17:51 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040220031751.GA20022@krispykreme>
References: <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218153234.3956af3a.akpm@osdl.org> <20040219123237.B22406@infradead.org> <20040219105608.30d2c51e.akpm@osdl.org> <20040219190141.A26888@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040219190141.A26888@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, paulmck@us.ibm.com, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

 
> You've probably not seen the AIX VM architecture.  Good for you as it's
> not good for your stomache.  I did when I still was SCAldera and although
> my NDAs don't allow me to go into details I can tell you that the AIX
> VM architecture is deeply tied into the segment architecture of the Power
> CPU and signicicantly different from any other UNIX variant.

Interesting, what version of AIX did you get access to? And how can you
be sure thats still the case?

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
