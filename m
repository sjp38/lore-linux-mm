Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9DA86B0267
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 21:02:58 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so131416970wjb.7
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 18:02:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 80si6562940wmy.107.2017.01.07.18.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Jan 2017 18:02:57 -0800 (PST)
Date: Sat, 7 Jan 2017 21:02:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
Message-ID: <20170108020252.GB16312@cmpxchg.org>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk>
 <20170106165941.GA19083@cmpxchg.org>
 <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk>
 <20170107011931.GA9698@cmpxchg.org>
 <20170108000737.q3ukpnils5iifulg@codemonkey.org.uk>
 <alpine.LSU.2.11.1701071626290.1664@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1701071626290.1664@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@codemonkey.org.uk>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Sat, Jan 07, 2017 at 04:37:43PM -0800, Hugh Dickins wrote:
> On Sat, 7 Jan 2017, Dave Jones wrote:
> > On Fri, Jan 06, 2017 at 08:19:31PM -0500, Johannes Weiner wrote:
> > 
> >  > Argh, __radix_tree_delete_node() makes the flawed assumption that only
> >  > the immediate branch it's mucking with can collapse. But this warning
> >  > points out that a sibling branch can collapse too, including its leaf.
> >  > 
> >  > Can you try if this patch fixes the problem?
> > 
> > 18 hours and still running.. I think we can call it good.
> 
> I'm inclined to agree, though I haven't had it running long enough
> (on a load like when it hit me a few times before) to be sure yet myself.
> I'd rather see the proposed fix go in than wait longer for me:
> I've certainly seen nothing bad from it yet.

Thank you both!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
