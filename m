Message-ID: <3B813743.5080400@ucla.edu>
Date: Mon, 20 Aug 2001 09:13:55 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: 2.4.8/2.4.9 VM problems
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> Could you please try this patch against 2.4.9 (patch -p0):
> 
> --- ../2.4.9.clean/mm/memory.c	Mon Aug 13 19:16:41 2001
> +++ ./mm/memory.c	Sun Aug 19 21:35:26 2001
> @@ -1119,6 +1119,7 @@
>  			 */
>  			return pte_same(*page_table, orig_pte) ? -1 : 1;
>  		}
> +		SetPageReferenced(page);
>  	}
>  
>  	/*
> 


Well, I tried this, and.... WOW!  Much better  [:)]
Was it really true, that swapped in pages didn't get marked as 
referenced before?  It almost felt that bad, but that seems kind of 
crazy - I don't completely understand what this fix is doing...

-BenRI
P.S. I tried this on my 64Mb PPro and a 128Mb PIII, and both felt like 
they had a lot more memory - e.g. less swapping and stuff.
-- 
"I will begin again" - U2, 'New Year's Day'
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
