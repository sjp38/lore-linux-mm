Subject: Re: [PATCH] vmalloc_32 should use GFP_KERNEL
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070717233358.2edeaac0.akpm@linux-foundation.org>
References: <1184739934.25235.220.camel@localhost.localdomain>
	 <20070717233358.2edeaac0.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 18 Jul 2007 16:49:14 +1000
Message-Id: <1184741354.25235.222.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dave Airlie <airlied@gmail.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-17 at 23:33 -0700, Andrew Morton wrote:
> whoops, yes.
> 
> Are those errors serious and common enough for 2.6.22.x?  

No idea, so far, the nouveau DRM isn't something I would recommend to
people to use in stable environments but heh... I don't know who else
uses vmalloc_32.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
