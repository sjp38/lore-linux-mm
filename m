Date: Fri, 11 Jul 2008 22:56:00 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 2/5] Add new GFP flag __GFP_NOTRACE.
Message-ID: <20080711225600.6532b9cf@linux360.ro>
In-Reply-To: <48777110.3000104@linux-foundation.org>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	<20080710210606.65e240f4@linux360.ro>
	<48777110.3000104@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 09:41:20 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> Eduard - Gabriel Munteanu wrote:
> 
> > This is used by kmemtrace to correctly classify different kinds of
> > allocations, without recording one event multiple times. Example:
> > SLAB's kmalloc() calls kmem_cache_alloc(), but we want to record
> > this only as a kmalloc.
> 
> Well then I guess we need to put the recording logic into
> kmem_cache_alloc?

Okay, will do it another way. I thought there may be other legitimate
uses of something like __GFP_NOTRACE.


	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
