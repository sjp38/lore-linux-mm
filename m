Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 360756B0069
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 15:30:22 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so1713850046pgc.5
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 12:30:22 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id z3si86436055pfd.61.2017.01.08.12.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 12:30:21 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id 14so23602931pgg.1
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 12:30:21 -0800 (PST)
Date: Sun, 8 Jan 2017 12:30:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
In-Reply-To: <20170108020252.GB16312@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1701081224220.3711@eggly.anvils>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk> <20170106165941.GA19083@cmpxchg.org> <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk> <20170107011931.GA9698@cmpxchg.org> <20170108000737.q3ukpnils5iifulg@codemonkey.org.uk>
 <alpine.LSU.2.11.1701071626290.1664@eggly.anvils> <20170108020252.GB16312@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@codemonkey.org.uk>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Sat, 7 Jan 2017, Johannes Weiner wrote:
> On Sat, Jan 07, 2017 at 04:37:43PM -0800, Hugh Dickins wrote:
> > On Sat, 7 Jan 2017, Dave Jones wrote:
> > > On Fri, Jan 06, 2017 at 08:19:31PM -0500, Johannes Weiner wrote:
> > > 
> > >  > Argh, __radix_tree_delete_node() makes the flawed assumption that only
> > >  > the immediate branch it's mucking with can collapse. But this warning
> > >  > points out that a sibling branch can collapse too, including its leaf.
> > >  > 
> > >  > Can you try if this patch fixes the problem?
> > > 
> > > 18 hours and still running.. I think we can call it good.
> > 
> > I'm inclined to agree, though I haven't had it running long enough
> > (on a load like when it hit me a few times before) to be sure yet myself.
> > I'd rather see the proposed fix go in than wait longer for me:
> > I've certainly seen nothing bad from it yet.
> 
> Thank you both!

Been running successfully for 36 and 24 hours on two machines, each with
a different load that showed it much sooner before: I too call it good,
and thanks to Dave and you and Linus for getting the fix in for -rc3.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
