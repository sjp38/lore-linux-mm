Message-Id: <200506271942.j5RJgig23410@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [rfc] lockless pagecache
Date: Mon, 27 Jun 2005 12:42:44 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.62.0506271221540.21616@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Lameter' <christoph@lameter.com>
Cc: 'Badari Pulavarty' <pbadari@us.ibm.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote on Monday, June 27, 2005 12:23 PM
> On Mon, 27 Jun 2005, Chen, Kenneth W wrote:
> > I don't recall seeing tree_lock to be a problem for DSS workload either.
> 
> I have seen the tree_lock being a problem a number of times with large 
> scale NUMA type workloads.

I totally agree!  My earlier posts are strictly referring to industry
standard db workloads (OLTP, DSS).  I'm not saying it's not a problem
for everyone :-)  Obviously you just outlined a few ....

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
