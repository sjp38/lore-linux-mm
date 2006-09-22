From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
Date: Fri, 22 Sep 2006 22:48:27 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <4514441E.70207@mbligh.org> <Pine.LNX.4.64.0609221321280.9181@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221321280.9181@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609222248.27700.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 22 September 2006 22:23, Christoph Lameter wrote:
> Here is an iniitial patch of alloc_pages_range (untested, compiles). 
> Directed reclaim missing. Feedback wanted. There are some comments in the 
> patch where I am at the boundary of my knowledge and it would be good if 
> someone could supply the info needed.

Looks like a good start. Surprising how little additional code it is.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
