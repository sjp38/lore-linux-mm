Date: Wed, 8 Nov 2000 10:05:33 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Question about swap_in() in 2.2.16 ....
Message-ID: <20001108100533.C11411@redhat.com>
References: <3A08F37A.38C156C1@cse.iitkgp.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A08F37A.38C156C1@cse.iitkgp.ernet.in>; from sganguly@cse.iitkgp.ernet.in on Wed, Nov 08, 2000 at 01:32:26AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 08, 2000 at 01:32:26AM -0500, Shuvabrata Ganguly wrote:
> 
> after the missing page has been swapped in this bit of code is
> executed:-
> 
> if (!write_access || is_page_shared(page_map)) {
>       set_pte(page_table, mk_pte(page, vma->vm_page_prot));
>       return 1;
>  }
> 
> Now this creates a read-only mapping  even if the access was a "write
> acess"  ( if the page is shared ). Doesnt this mean that an additional
> "write-protect" fault will be taken immediately when the process tries
> to write again ?

Yes.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
