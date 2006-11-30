Date: Wed, 29 Nov 2006 20:15:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to
 userspace
In-Reply-To: <6599ad830611291625uf599963k7e6ff351c2b73e34@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611292014080.19628@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061129033826.268090000@menage.corp.google.com>
 <20061130091815.018f52fd.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611291625uf599963k7e6ff351c2b73e34@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Paul Menage wrote:

> In which kernel version? In 2.6.19-rc6 (also -mm1) there's no panic in
> isolate_lru_page().

Depends on the hardware and the linux configuration sparsemem, 
virtual_memmap etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
