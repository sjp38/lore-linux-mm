Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EAB1D6B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 19:29:39 -0500 (EST)
Message-ID: <4B1857ED.30304@redhat.com>
Date: Thu, 03 Dec 2009 19:29:33 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
References: <20091125133752.2683c3e4@bree.surriel.com>	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com>	 <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>	 <4B15CEE0.2030503@redhat.com> <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/03/2009 05:14 PM, Larry Woodman wrote:

> The attached patch addresses this issue by changing page_check_address()
> to return -1 if the spin_trylock() fails and page_referenced_one() to
> return 1 in that path so the page gets moved back to the active list.

Your patch forgot to add the code to vmscan.c to actually move
the page back to the active list.

Also, please use an enum for the page_referenced return
values, so the code in vmscan.c can use symbolic names.

enum page_reference {
	NOT_REFERENCED,
	REFERENCED,
	LOCK_CONTENDED,
};

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
