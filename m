Date: Thu, 19 Oct 2006 09:43:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
In-Reply-To: <453796BC.8050600@shadowen.org>
Message-ID: <Pine.LNX.4.64.0610190942050.8072@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
 <453796BC.8050600@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, linux-ia64@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006, Andy Whitcroft wrote:

> This is a good thing too as one of the main issues we've had with the
> VIRTUAL_MEMMAP stuff is this need to pfn_valid each and every
> conversion.  Of course the same change could be applied there just as well.

Well it should have been done instead of adding this strange hole logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
