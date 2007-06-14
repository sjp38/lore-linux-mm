Date: Thu, 14 Jun 2007 07:19:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
In-Reply-To: <20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
 <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
 <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
 <20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:

> But...during discussion with you, I found anon_vma is now freed by RCU...
> 
> Ugh, then, what I have to do is  rcu_read_lock() -> rcu_read_unlock() while
> migrating anon ptes. If we can rcu read lock here, we don't need dummy_vma.
> How about this ?

Hmmmm... Looks good. Maybe take the RCU lock unconditionally? Is there a 
problem if we do so? Then the patch becomes very small and it looks 
cleaner. 

Is there an issue with calling try_to_unmap for an unmapped page? We check 
in try_to_unmap if the pte is valid. If it was unmapped then try_to_unmap 
will fail anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
