Date: Thu, 12 Dec 2002 10:29:30 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Question on set_page_dirty()
Message-ID: <20021212102930.C15158@nightmaster.csn.tu-chemnitz.de>
References: <3DF5BB06.A6F6AFFD@scs.ch> <20021211080102.GG20525@vagabond>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021211080102.GG20525@vagabond>; from bulb@ucw.cz on Wed, Dec 11, 2002 at 09:01:02AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Hudec <bulb@ucw.cz>, Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Dec 11, 2002 at 09:01:02AM +0100, Jan Hudec wrote:
> > What is the meaning of this dirty queue, what is the effect of linking
> > a page onto that queue, and when should the set_page_dirty() function
> > be used rather than the
> > SetPageDirty() macro?
> 
> If you use the SetPageDirty macro, then the page is marked dirty, but
> kernel can't find it when it should clean it. Thus it eventualy won't
> flush the data (it won't call writepage on it).

set_page_dirty() can be used in all cases, IMHO, since it:
   - will not sleep
   - will not call the set_page_dirty() method, if page has been dirty
     before (test_and_set_XXX is atomic an guarantees to trigger
     once only)
   - will not do anything besides settingt the PG_Dirty bit,
     if the page contains no mapping, or does not contain a
     set_page_dirty_method

So if set_page_dirty() exists on a certain kernel you want to
support, it should be used in all cases. Accounting code can also
be hooked into this, if it is used properly.

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
