Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE236B0266
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 19:37:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so54791797pgb.0
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 16:37:53 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id l33si84329642pld.41.2017.01.07.16.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Jan 2017 16:37:52 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id y143so725008pfb.0
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 16:37:52 -0800 (PST)
Date: Sat, 7 Jan 2017 16:37:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
In-Reply-To: <20170108000737.q3ukpnils5iifulg@codemonkey.org.uk>
Message-ID: <alpine.LSU.2.11.1701071626290.1664@eggly.anvils>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk> <20170106165941.GA19083@cmpxchg.org> <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk> <20170107011931.GA9698@cmpxchg.org> <20170108000737.q3ukpnils5iifulg@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Jones <davej@codemonkey.org.uk>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Sat, 7 Jan 2017, Dave Jones wrote:
> On Fri, Jan 06, 2017 at 08:19:31PM -0500, Johannes Weiner wrote:
> 
>  > Argh, __radix_tree_delete_node() makes the flawed assumption that only
>  > the immediate branch it's mucking with can collapse. But this warning
>  > points out that a sibling branch can collapse too, including its leaf.
>  > 
>  > Can you try if this patch fixes the problem?
> 
> 18 hours and still running.. I think we can call it good.

I'm inclined to agree, though I haven't had it running long enough
(on a load like when it hit me a few times before) to be sure yet myself.
I'd rather see the proposed fix go in than wait longer for me:
I've certainly seen nothing bad from it yet.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
