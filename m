Date: Fri, 1 Dec 2006 11:56:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830612011132i3e70ab38ye3bc8e48f879fea3@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0612011156100.18846@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
 <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
 <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
 <Pine.LNX.4.64.0611301821270.14059@schroedinger.engr.sgi.com>
 <6599ad830612011132i3e70ab38ye3bc8e48f879fea3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006, Paul Menage wrote:

> 
> I was thinking of a new anon_vma, rather than a new vma - but I guess
> that even if we do race with someone who's faulting on the page and
> pulling it from the swap cache, they'll just set the page mapping to
> the same value as it is already, rather than setting it to a new
> value. So you're right, not a problem.

The page is locked during migration to prevent such occurrences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
