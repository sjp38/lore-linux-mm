Date: Thu, 6 Apr 2006 09:45:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/3] mm: An enhancement of OVERCOMMIT_GUESS
Message-Id: <20060406094533.b340f633.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4434570F.9030507@redhat.com>
References: <4434570F.9030507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hideo AOKI <haoki@redhat.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, AOKI-san

On Wed, 05 Apr 2006 19:47:27 -0400
Hideo AOKI <haoki@redhat.com> wrote:

> Hello Andrew,
> 
> Could you apply my patches to your tree?
> 
> These patches are an enhancement of OVERCOMMIT_GUESS algorithm in
> __vm_enough_memory(). The detailed description is in attached patch.
> 

I think adding a function like this is more simple way.
(call this istead of nr_free_pages().)
==
int nr_available_memory() 
{
	unsigned long sum = 0;
	for_each_zone(zone) {
		if (zone->free_pages > zone->pages_high)
			sum += zone->free_pages - zone->pages_high;
	}
	return sum;
}
==

BTW, vm_enough_memory() doesn't eat cpuset information ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
