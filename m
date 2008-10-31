Subject: Re: [PATCH] slab: unsigned slabp->inuse cannot be less than 0
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0810301350490.30797@quilx.com>
References: <4908D30F.1020206@gmail.com> <4909FBAE.4080002@cs.helsinki.fi>
	 <Pine.LNX.4.64.0810301350490.30797@quilx.com>
Date: Fri, 31 Oct 2008 10:54:44 +0200
Message-Id: <1225443284.19537.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: roel kluin <roel.kluin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-30 at 13:51 -0500, Christoph Lameter wrote:
> Ok here it is. But I think you are well capable of reviewing trivial 
> patches on your own.
> 
> Acked-by: Christoph Lameter <cl@linux-foundation.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
