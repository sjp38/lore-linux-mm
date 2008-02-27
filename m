Date: Wed, 27 Feb 2008 11:20:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/18] Define functions for page cache handling
In-Reply-To: <20080223152716.51cc3875.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802271118020.32462@schroedinger.engr.sgi.com>
References: <20080216004718.047808297@sgi.com> <20080216004805.610589231@sgi.com>
 <20080223152716.51cc3875.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Feb 2008, Andrew Morton wrote:

> But the interfaces which they use (passing and address_space) are quite
> pointless unless we implement variable page size per address_space.  And as
> the chances of that ever happening seem pretty damn small, these changes
> are just obfuscation which make the code harder to read and which
> pointlessly churn the codebase.
> 
> So I'm inclined to drop these patches.

Ummm.. I can submit the rest of the code to make this work? The rest is 
available at git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git

Branches

vcompound	Fallback for compound pages to order 0 allocs
largeblock	Based on vcompound, large block support for devices and FS.


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
