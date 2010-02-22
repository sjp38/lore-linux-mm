Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 786AD6001DA
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:57:34 -0500 (EST)
Message-ID: <4B82C518.2030005@redhat.com>
Date: Mon, 22 Feb 2010 12:55:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 29/36] page anon_vma
References: <20100221141009.581909647@redhat.com> <20100221141757.404104520@redhat.com>
In-Reply-To: <20100221141757.404104520@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/21/2010 09:10 AM, aarcange@redhat.com wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Find the anon_vma to lock from the page rather than from the vma, after recent
> anon_vma changes that allows a vma to belong to more than a single anon_vma.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

This could be folded into earlier patches, so bisectability
is preserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
