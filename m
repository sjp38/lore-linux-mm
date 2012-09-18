Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0F5116B0075
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 06:02:19 -0400 (EDT)
Date: Tue, 18 Sep 2012 11:02:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Does swap_set_page_dirty() calling ->set_page_dirty() make sense?
Message-ID: <20120918100215.GK11266@suse.de>
References: <20120917163518.GD9150@quack.suse.cz>
 <alpine.LSU.2.00.1209171204100.6720@eggly.anvils>
 <20120918021627.GF9150@quack.suse.cz>
 <201209181051.50541.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201209181051.50541.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, Sep 18, 2012 at 10:51:50AM +0200, Petr Tesarik wrote:
> > <SNIP>
> > 
> > So just one minor nit for Mel. SWP_FILE looks like a bit confusing name for
> > a flag that gets set only for some swap files ;) At least I didn't pay
> > attention to it because I thought it's set for all of them. Maybe call it
> > SWP_FILE_CALL_AOPS or something like that?
> 

I guess it would be a slightly better name all right.

> Same here. In fact, I believed that other filesystems only work by accident 
> (because they don't have to access the mapping). I'm not even sure about the 
> semantics of the swap_activate operation. Is this documented somewhere?
> 

Documentation/filesystems/vfs.txt *briefly* describes what swap_activate()
does even though now that I read it I see that it's inaccurate. It says
that it proxies to the address spaces swapin_[out|in] method but it really
gets proxied to the direct_IO interface for writes and readpage for reads
(direct_IO could have been used for reads but my recollection was that
the locking was very awkward).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
