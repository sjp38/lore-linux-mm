Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 44F4A6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:01:06 -0500 (EST)
Date: Sat, 14 Nov 2009 03:00:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <20091113115026.GU21482@random.random>
References: <20091113172453.33CB.A69D9226@jp.fujitsu.com> <20091113115026.GU21482@random.random>
Message-Id: <20091114025202.3DAB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, Nov 13, 2009 at 05:26:14PM +0900, KOSAKI Motohiro wrote:
> > Probably we can remove VM_NONLINEAR perfectly. I've never seen real user of it.
> 
> Do you mean as a whole or in the mlock logic? databases are using
> remap_file_pages on 32bit archs to avoid generating zillon of vmas on
> tmpfs scattered mappings. On 64bits it could only be useful to some
> emulators but with real shadow paging and nonlinear rmap already
> created on shadow pagetables, it looks pretty useless on 64bit archs
> to me.

Hehe, you point out kosaki is stupid and knoledgeless.
thanks correct me.

Probaby we have to maintain VM_NONLINEAR for one or two year. two years
later, nobody use database on 32bit machine.
(low-end DB might be use on 32bit, but that's ok. it doesn't use VM_NONLINEAR)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
