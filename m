Date: Fri, 16 Jun 2000 11:05:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: shrink_mmap bug in 2.2?
Message-ID: <20000616110502.A1202@redhat.com>
References: <20000614185034.A2505@acs.ucalgary.ca> <200006150116.SAA41023@google.engr.sgi.com> <20000615131241.D9717@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000615131241.D9717@acs.ucalgary.ca>; from nascheme@enme.ucalgary.ca on Thu, Jun 15, 2000 at 01:12:41PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 15, 2000 at 01:12:41PM -0600, Neil Schemenauer wrote:
> 
> If the page is not referenced it will be removed regardless of
> the swap_count.  My question is "does swap_count have to equal
> one before calling delete_from_swap_cache"?  If it does then I
> think the code is wrong.

No.  The swap cache is only an in-memory cached copy of the on-disk
swap page.  It is quite safe to delete the swap cache page in memory
no matter how many references to the on-disk copy there are.  If
this were not true, we'd be unable to delete any swapped-out pages
from ram!

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
