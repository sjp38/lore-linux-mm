Message-ID: <41E4295F.1010909@sgi.com>
Date: Tue, 11 Jan 2005 13:30:39 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <41DB35B8.1090803@sgi.com> <m1wtusd3y0.fsf@muc.de> <41DB5CE9.6090505@sgi.com> <41DC34EF.7010507@mvista.com> <41E3F2DA.5030900@sgi.com> <41E42268.5090404@mvista.com>
In-Reply-To: <41E42268.5090404@mvista.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Andi Kleen <ak@muc.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Steve Longerbeam wrote:


> 
> isn't this already taken care of? read_swap_cache_async() is given
> a vma, and passes it to alloc_page_vma(). So if you have earlier
> changed the policy for that vma, the new policy will be used
> when allocating the page during the swap in.
> 
> Steve
> 

What if the policy associated with a vma is the default policy?
Then the page will be swapped in on the node that took the page
fault -- this is >>probably<< correct in most cases, but if a
page is accessed from several nodes, and predominately accessed
from a particular node, it can end up moving due to being swapped
out, and that is probably not what the application intended.

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
