Date: Thu, 28 Oct 2004 09:19:11 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] sparsemem patches (was nonlinear)
Message-ID: <1278150000.1098980350@[10.10.2.4]>
In-Reply-To: <418118A1.9060004@us.ibm.com>
References: <098973549.shadowen.org> <418118A1.9060004@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Have you given any thought to using virt_to_page(page)->foo method to 
> store section information instead of using page->flags?  It seems we're 
> already sucking up page->flags left and right, and I'd hate to consume 
> that many more.

It doesn't add any more. It reuses the existing overload space.
Only exception was if you wanted a billion piddly little segments on a 32bit.
Tough, don't do that ;-) For 64 bit, it's a non-issue.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
