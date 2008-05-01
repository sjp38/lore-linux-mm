Date: Thu, 1 May 2008 13:34:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
In-Reply-To: <20080501202520.GA12354@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0805011333430.9486@schroedinger.engr.sgi.com>
References: <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com>
 <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org>
 <20080425165424.GA9680@us.ibm.com> <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com>
 <20080425192942.GB14623@us.ibm.com> <Pine.LNX.4.64.0804301215220.27955@schroedinger.engr.sgi.com>
 <20080430204428.GC6903@us.ibm.com> <Pine.LNX.4.64.0805011222350.8738@schroedinger.engr.sgi.com>
 <20080501202520.GA12354@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Thu, 1 May 2008, Nishanth Aravamudan wrote:

> I'm pretty sure when I first created alloc_huge_page_node(), you argued
> for me *not* using page_to_nid() on the returned page because we expect
> __GFP_THISNODE to do the right thing.

I vaguely remember that the issue at that point was that you were trying 
to compensate for __GFP_THISNODE brokenness?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
