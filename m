Date: Wed, 29 Nov 2006 20:17:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Paul Menage wrote:

> Hmm, isn't migration just analagous to swapping out and swapping back
> in again, but without the actual swapping?

That used to be the case in the beginning. Not anymore. The page is 
directly moved to the target. Migration via swap is no longer supported.
 
> If what you describe is a problem, then wouldn't you have a problem if
> you were doing migration on a particular mm structure, but it was
> sharing pages with another mm?

You do not have a problem as long as you hold a mmap_sem lock on any of 
the vmas in which the page appears. Kame and I discussed several 
approached on how to avoid the issue in the past but so far there was no 
need to resolve the issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
