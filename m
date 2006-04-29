Date: Fri, 28 Apr 2006 17:46:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/7] page migration: synchronize from and to lists
In-Reply-To: <20060429094449.6b1c9c52.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604281746370.4378@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428060323.30257.90761.sendpatchset@schroedinger.engr.sgi.com>
 <20060428164619.4b8bc28c.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604280830020.32339@schroedinger.engr.sgi.com>
 <20060429092743.9548531d.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604281732460.4311@schroedinger.engr.sgi.com>
 <20060429094449.6b1c9c52.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Sat, 29 Apr 2006, KAMEZAWA Hiroyuki wrote:

> > You can control exactly where each page is migrated. Currently a page on 
> > from is migrated to some page on the to list.
> > 
> Then, array is sane interface rather than list, I think.

Hmmm. Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
