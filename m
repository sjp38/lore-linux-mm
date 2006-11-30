Date: Thu, 30 Nov 2006 10:28:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Paul Menage wrote:

> OK, so we could do the same, and just assume that pages with a
> page_mapcount() of 0 are either about to be freed or can be picked up
> on a later migration sweep. Is it common for a page to have a 0
> page_mapcount() for a long period of time without being freed or
> remapped?

page mapcount goes to zero during migration because the references to the 
page are removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
