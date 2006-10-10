Date: Mon, 9 Oct 2006 23:34:12 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
In-Reply-To: <20061009215125.619655b2.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0610092331120.17087@attu3.cs.washington.edu>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
 <20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
 <20061009111203.5dba9cbe.akpm@osdl.org> <20061009150259.d5b87469.pj@sgi.com>
 <20061009215125.619655b2.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2006, Paul Jackson wrote:

> -However- that forces a per-node reference in the zonelist caching
> code as part of the scan for a free page.  That is exactly what we
> were trying to avoid!
> 
> No.  Not count frees either.  Don't count anything.
> 

When a free occurs for a given zone, increment its counter.  If that 
reaches some threshold, zap that node in the nodemask so it's checked on 
the next alloc.  All the infrastructure is already there for this support 
in your patch.

[ Note: rientjes@google.com is no longer valid so I've removed it (again)
  from the Cc list.  My email address is rientjes@cs.washington.edu. ]

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
