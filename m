Date: Wed, 21 Jun 2000 16:23:30 -0400 (EDT)
From: Puppetmaster <akhripin@mbhs.edu>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
In-Reply-To: <20000621200418Z131176-21004+46@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.10006211622270.10983-100000@binx.mbhs.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2000, Timur Tabi wrote:

> ** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
> Jun 2000 12:56:12 -0700 (PDT)
> 
> 
> > This is a left over from the days when we had a few more __GFP_ flags,
> > but that has been cleaned up now, so NR_GFPINDEX can go down. 
> 
> Cool.  I'm glad to see that my questions wasn't stupid :-)
> 
> >Be aware 
> > of any cache footprint issues though.
> 
> Ok, you just lost me.  What's a "cache footprint"?
Cache footprint refers to the amount of space code/data take up in the
cache. This is important for code that is frequently executed, as it is
very good performance-wise to have the nescessary data and code entirely
in the L1 cache.
 > 
> 
> 
> 
> --
> Timur Tabi - ttabi@interactivesi.com
> Interactive Silicon - http://www.interactivesi.com
> 
> When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

-- 
Master! Master! Where's the dreams that I've been after?
           Master! Master! Promised only lies!         
  Laughter! Laughter! All I hear and see is laughter,
       Laughter! Laughter! Laughing at my cries!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
