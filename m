Date: Thu, 30 Nov 2006 11:42:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Paul Menage wrote:

> On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > F.e. A page cache page may have mapcount == 0.
> 
> OK, I was thinking just about anon pages.
> 
> For pagecache pages, it's safe to access the mapping as long as we've
> locked the page, even if mapcount is 0? So we don't have the same
> races?

We have no problem with the page lock (you actually may not need any 
locking since there are no references remaining to the page). The trouble 
is that the vma may have vanished when we try to reestablish the pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
