Date: Fri, 8 Jun 2007 09:31:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.22-rc4-mm1
Message-Id: <20070608093113.4691644b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070607083458.a3fc7737.akpm@linux-foundation.org>
References: <20070606020737.4663d686.akpm@linux-foundation.org>
	<20070607214706.3efc5870.kamezawa.hiroyu@jp.fujitsu.com>
	<20070607083458.a3fc7737.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, clameter@sgi.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 08:34:58 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> I assume the above is your code - it's not in the tree?
> 
Ah, that code was disappeared in -mm2. 

But it informed me that I should consider memory unplug v.s. sys_mremap case... 

Thanks, anyway.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
