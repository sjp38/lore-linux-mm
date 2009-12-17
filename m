Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4D3D6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:03:23 -0500 (EST)
Date: Wed, 16 Dec 2009 16:02:53 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH -stable] vmalloc: conditionalize build of
 pcpu_get_vm_areas()
Message-ID: <20091217000253.GA3225@kroah.com>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
 <20091207153552.0fadf335.akpm@linux-foundation.org>
 <4B1E1B1B0200007800024345@vpn.id2.novell.com>
 <4B1E0E56.8020003@kernel.org>
 <4B1E1EE60200007800024364@vpn.id2.novell.com>
 <4B1E1513.3020000@kernel.org>
 <4B203614.1010907@novell.com>
 <20091216231210.GB9421@kroah.com>
 <4B2974F0.1030505@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B2974F0.1030505@novell.com>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <teheo@novell.com>
Cc: stable@kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Beulich <JBeulich@novell.com>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 09:01:52AM +0900, Tejun Heo wrote:
> Hello, Greg.
> 
> On 12/17/2009 08:12 AM, Greg KH wrote:
> >> Please note that this commit won't appear on upstream.
> > 
> > So this is only needed for the .32 kernel stable tree?  Not .31?  And
> > it's not upstream as it was solved differently there?
> 
> Yeap, .32 is the only affected one and in the upstream the problem is
> solved way back and ia64 is already using the new dynamic allocator.

Great, I've queued this up now, thanks for letting me know.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
