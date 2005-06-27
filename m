Message-Id: <200506271905.j5RJ5ag22991@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [rfc] lockless pagecache
Date: Mon, 27 Jun 2005 12:05:36 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1119898264.13376.89.camel@dyn9047017102.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Badari Pulavarty' <pbadari@us.ibm.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote on Monday, June 27, 2005 11:51 AM
> On Mon, 2005-06-27 at 11:14 -0700, Chen, Kenneth W wrote:
> > Typically shared memory is used as db buffer cache, and O_DIRECT is
> > performed on these buffer cache (hence O_DIRECT on the shared memory).
> > You must be thinking some other workload.  Nevertheless, for OLTP type
> > of db workload, tree_lock hasn't been a problem so far.
> 
> What about DSS ? I need to go back and verify some of the profiles
> we have.

I don't recall seeing tree_lock to be a problem for DSS workload either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
