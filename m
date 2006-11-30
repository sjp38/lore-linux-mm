Date: Thu, 30 Nov 2006 12:00:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
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
> > We have no problem with the page lock (you actually may not need any
> > locking since there are no references remaining to the page). The trouble
> > is that the vma may have vanished when we try to reestablish the pte.
> > 
> 
> Why is that a problem? If the vma has gone away, then there's no need
> to reestablish the pte. And remove_file_migration_ptes() appears to be
> adequately protected against races with unlink_file_vma() since they
> both take i_mmap_sem.

We are talking about anonymous pages here. You cannot figure out 
that the vma is gone since that was the only connection to the process. 
Hmm... Not true we still have a migration pte in that processes space. But 
we cannot find the process without the anon_vma.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
