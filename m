Message-ID: <20020719184058.44876.qmail@web14303.mail.yahoo.com>
Date: Fri, 19 Jul 2002 11:40:58 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: [patch] Useless locking in mm/numa.c
In-Reply-To: <20020719183844.GJ1022@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: colpatch@us.ibm.com, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, linux-mm@kvack.org, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--- William Lee Irwin III <wli@holomorphy.com> wrote:
> On Fri, Jul 19, 2002 at 11:36:46AM -0700, Kanoj
> Sarcar wrote:
> > I think I put in the locks in the initial version
> of
> > the file becase the idea was that 
> > show_free_areas_node() could be invoked from any
> cpu
> > in a multinode system (via the sysrq keys or other
> > intr sources), and the spin lock would provide 
> > sanity in the print out. 
> > For nonnuma discontig machines, isn't the spin
> lock
> > providing protection in the pgdat list chain
> walking
> > in _alloc_pages()?
> > Kanoj
> 
> Since I just posted a patch removing the entire
> function, exactly
> where is this called from? A grep of current 2.5
> shows that it's
> never called from anywhere.
> 
> 
> Cheers,
> Bill

Ok. I was just pointing out why the lock was added
initially. The reasons might not make sense anymore.

Kanoj


__________________________________________________
Do You Yahoo!?
Yahoo! Autos - Get free new car price quotes
http://autos.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
