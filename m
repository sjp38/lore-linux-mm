Date: Wed, 14 Jun 2000 18:50:34 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: shrink_mmap bug in 2.2?
Message-ID: <20000614185034.A2505@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This code looks strange to me (possibly because I don't
understand it):

    /*
     * Is it a page swap page? If so, we want to
     * drop it if it is no longer used, even if it
     * were to be marked referenced..
     */
    if (PageSwapCache(page)) {
            if (referenced && swap_count(page->offset) != 1)
                    continue;
            delete_from_swap_cache(page);
            return 1;
    }       

Can pages be deleted from the swap cache if swap_count is not
one?  If not, then I think this code is wrong.  It should be:

    if (PageSwapCache(page)) {
            if (swap_count(page->offset) != 1)
                    continue;
            delete_from_swap_cache(page);
            return 1;
    }       
 
Thanks in advance for any help.

    Neil

-- 
"God, root, what is difference?" - Pitr
"God is more forgiving." - Dave Aronson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
