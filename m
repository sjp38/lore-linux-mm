Date: Mon, 23 Jan 2006 19:00:03 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <AD640FEA47356D8F9DCEE227@[10.1.1.4]>
In-Reply-To: <200601231853.54948.raybry@mpdtxmail.amd.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231816.38942.raybry@mpdtxmail.amd.com>
 <200601240139.46751.ak@suse.de>
 <200601231853.54948.raybry@mpdtxmail.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>, Andi Kleen <ak@suse.de>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Monday, January 23, 2006 18:53:54 -0600 Ray Bryant
<raybry@mpdtxmail.amd.com> wrote:

> Isn't it the case that if the region is large enough (say >> 2MB), that 
> randomized mmaps will just cause the first partial page of pte's to not
> be  shareable, and as soon as we have a full pte page mapped into the
> file that  the full pte pages will be shareable, etc, until the last
> (partial) pte page  is not shareable?

Yes, but only if the 2MB alignment is the same.  And with the current
version of my patch the region has to be mapped at the same address in both
processes.  Sorry.

Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
