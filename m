Date: Fri, 25 May 2007 06:42:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/6] Compound Page Enhancements
In-Reply-To: <20070525170533.2987b7b2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705250642100.5199@schroedinger.engr.sgi.com>
References: <20070525051716.030494061@sgi.com> <20070525170533.2987b7b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, KAMEZAWA Hiroyuki wrote:

> Keeping "free high order page" as "free compound page" in free_area[]-> and
> avoid calling prep_compound_page() in page allocation ?

Right. That would be one benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
