Date: Wed, 25 Jul 2007 13:03:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.23-rc1-mm1:  boot hang on ia64 with memoryless nodes
In-Reply-To: <Pine.LNX.4.64.0707251231570.8820@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0707251301070.9983@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>  <20070713151431.GG10067@us.ibm.com>
  <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
 <1185310277.5649.90.camel@localhost>  <Pine.LNX.4.64.0707241402010.4773@schroedinger.engr.sgi.com>
  <1185372692.5604.22.camel@localhost>  <1185378322.5604.43.camel@localhost>
 <1185390991.5604.87.camel@localhost> <Pine.LNX.4.64.0707251231570.8820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kxr@sgi.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Mel Gorman <mel@skynet.ie>, Eric Whitney <eric.whitney@hp.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Christoph Lameter wrote:

> I get a similar hang here and see the system looping in softirq / hrtimer 
> code.

Keith Rich also has a hang with current git. My hang was with 2.6.23-rc1.
Keith Owens has significant issues with 2.6.23-rc1. Lets get this onto 
linux-ia64. I do not think we can do any testing with 2.6.23-rc1-mm1 until 
we have ironed out the issues in the base kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
