Message-ID: <41DC7542.8010305@sgi.com>
Date: Wed, 05 Jan 2005 17:16:18 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <41DB35B8.1090803@sgi.com> <m1wtusd3y0.fsf@muc.de> <41DB5CE9.6090505@sgi.com> <41DC34EF.7010507@mvista.com> <41DC3E96.4020807@sgi.com> <41DC7193.60505@mvista.com>
In-Reply-To: <41DC7193.60505@mvista.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Andi Kleen <ak@muc.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Steve Longerbeam wrote:

> 
> you mean like a global mempolicy for the page cache? This shouldn't
> be difficult to integrate with my patch, ie. when allocating a page
> for the cache, first check if the mapping object has a policy (my patch),
> if not, then check if there is a global pagecache policy (your patch).
> 

Yes, I think thats exactly what I am thinking of.

I'll take a look at your patch and see what develops.  :-)
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
