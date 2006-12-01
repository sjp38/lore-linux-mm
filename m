Date: Thu, 30 Nov 2006 18:43:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <20061201114414.0c90f649.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611301842190.14237@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
 <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
 <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
 <20061201114414.0c90f649.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, hugh@veritas.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006, KAMEZAWA Hiroyuki wrote:

> This is a patch. not tested at all, just idea level.
> (seems a period of taking rcu_read_lock() is a bit long..)

This is what we have been  trying to avoid. Using rcu means that the 
anon_vma cacheline gets cold and this will badly influence benchmarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
