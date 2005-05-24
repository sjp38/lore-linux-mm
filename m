Date: Tue, 24 May 2005 14:37:54 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: NUMA aware slab allocator V3
In-Reply-To: <428E56EE.4050400@us.ibm.com>
Message-ID: <Pine.LNX.4.62.0505241436460.3878@graphe.net>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>
 <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>
 <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net>
 <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com>
 <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com>
 <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com>
 <428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net>
 <Pine.LNX.4.62.0505182105310.17811@graphe.net> <428E3497.3080406@us.ibm.com>
 <Pine.LNX.4.62.0505201210460.390@graphe.net> <428E56EE.4050400@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 May 2005, Matthew Dobson wrote:

> I can't for the life of me explain why, but the above patch makes ALL the
> warnings go away, despite the fact that they seem unrelated.  I dunno...
> Maybe we should upgrade the compiler on that box?

Is the NUMA slab patch now working on ppc64?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
