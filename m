Date: Fri, 24 Dec 2004 08:24:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Prezeroing V2 [1/4]: __GFP_ZERO / clear_page() removal
In-Reply-To: <41CB25AE.6010109@didntduck.org>
Message-ID: <Pine.LNX.4.58.0412240823240.6561@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
 <41CB25AE.6010109@didntduck.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Gerst <bgerst@didntduck.org>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Dec 2004, Brian Gerst wrote:

> This part is wrong.  kmalloc() uses the slab allocator instead of
> getting a full page.

Thanks for finding that. V3 will have that fixed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
