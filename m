Date: Mon, 6 Aug 2007 13:15:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes
 V9
In-Reply-To: <1186429941.5065.24.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708061314030.7603@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com>  <20070806163726.GK15714@us.ibm.com>
  <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
 <20070806181912.GS15714@us.ibm.com>  <Pine.LNX.4.64.0708061136260.3152@schroedinger.engr.sgi.com>
 <1186429941.5065.24.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Lee Schermerhorn wrote:

> I don't understand what you're asking either.  The function that Nish is
> allocating the initial free huge page pool.  I thought that the intended
> behavior of this function was to distribute new allocated huge pages
> evenly across the nodes.  It was broken, in that for systems with
> memoryless nodes, the allocation would immediately fall back to the next
> node in the zonelist, overloading that node with huge page.  

I am all for distributing the pages evenly. The problem is that new 
functions are now exported from the memory policy layer. Exporting 
mpol_new() may be avoided by not using a policy. If we are just doing a 
round robin over a nodemask then this may be done in a different way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
