Date: Wed, 3 Nov 2004 01:54:15 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041103005415.GZ3571@dualathlon.random>
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <4188086F.8010005@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4188086F.8010005@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2004 at 02:21:35PM -0800, Dave Hansen wrote:
> OK, good to know.  But, for now, can we pull this out of -mm?  Or, at 

I doubt it's a good idea unless 1) you want the silent memleak back or
2) you found something wrong in the fix itself.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
