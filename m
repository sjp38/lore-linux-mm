Date: Fri, 14 Apr 2006 10:40:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Swapless V2: Revise main migration logic
Message-Id: <20060414104020.866ed279.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604131832020.16220@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
	<20060413235432.15398.23912.sendpatchset@schroedinger.engr.sgi.com>
	<20060414101959.d59ac82d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604131832020.16220@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2006 18:33:07 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 14 Apr 2006, KAMEZAWA Hiroyuki wrote:
> 
> > For hotremove (I stops it now..), we should fix this later (if we can do).
> > If new SWP_TYPE_MIGRATION swp entry can contain write protect bit,
> > hotremove can avoid copy-on-write but things will be more complicated.
> 
> This is a known issue.I'd be glad if you could come up with a working 
> scheme to solve this that is simple.
> 

Hmm. I'll post sample implemntation on your patch, later.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
