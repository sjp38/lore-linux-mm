Message-ID: <48777110.3000104@linux-foundation.org>
Date: Fri, 11 Jul 2008 09:41:20 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/5] Add new GFP flag __GFP_NOTRACE.
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro> <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro> <20080710210606.65e240f4@linux360.ro>
In-Reply-To: <20080710210606.65e240f4@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:

> This is used by kmemtrace to correctly classify different kinds of
> allocations, without recording one event multiple times. Example: SLAB's
> kmalloc() calls kmem_cache_alloc(), but we want to record this only as a
> kmalloc.

Well then I guess we need to put the recording logic into kmem_cache_alloc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
