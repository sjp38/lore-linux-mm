Date: Thu, 13 Sep 2007 10:41:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 16 of 24] avoid some lock operation in vm fast path
Message-Id: <20070913104139.702c5783.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0709121832130.4981@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random>
	<b343d1056f356d60de86.1187786943@v2.random>
	<20070912055952.bd5c99d6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709121746240.4489@schroedinger.engr.sgi.com>
	<20070912181636.8e807295.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709121832130.4981@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 18:33:48 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

>
> +int sysctl_reclaim_batch = SWAP_CLUSTER_MAX;
>  
nitpick...

should be __read_mostly ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
