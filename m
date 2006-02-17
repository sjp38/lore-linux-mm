From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 13:15:44 +0100
References: <200602170223.34031.ak@suse.de> <200602171058.33078.ak@suse.de> <20060217112324.GA31068@localhost>
In-Reply-To: <20060217112324.GA31068@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602171315.45419.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 February 2006 12:23, Bob Picco wrote:

> Yasunori thanks for mentioning memory less nodes for ia64.  This is my
> concern with the patch.

I very much doubt it worked before without this patch in 2.6.16-* (unless you have
the memory less nodes all at the end and not in the middle) 


> I need to test/review the patch on HP  
> hardware/simulator (most default configured HP NUMA machines are memory less - 
> interleaved memory). This has caused us numerous NUMA issues.

Yes, it's causing me problems on x86-64 all the time too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
