Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3FC0E6B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 05:08:47 -0400 (EDT)
Message-ID: <1351242480.12171.48.camel@twins>
Subject: Re: [PATCH 00/31] numa/core patches
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 26 Oct 2012 11:08:00 +0200
In-Reply-To: <508A52E1.8020203@redhat.com>
References: <20121025121617.617683848@chello.nl>
	 <508A52E1.8020203@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Fri, 2012-10-26 at 17:07 +0800, Zhouping Liu wrote:
> [  180.918591] RIP: 0010:[<ffffffff8118c39a>]  [<ffffffff8118c39a>] mem_c=
group_prepare_migration+0xba/0xd0

> [  182.681450]  [<ffffffff81183b60>] do_huge_pmd_numa_page+0x180/0x500
> [  182.775090]  [<ffffffff811585c9>] handle_mm_fault+0x1e9/0x360
> [  182.863038]  [<ffffffff81632b62>] __do_page_fault+0x172/0x4e0
> [  182.950574]  [<ffffffff8101c283>] ? __switch_to_xtra+0x163/0x1a0
> [  183.041512]  [<ffffffff8101281e>] ? __switch_to+0x3ce/0x4a0
> [  183.126832]  [<ffffffff8162d686>] ? __schedule+0x3c6/0x7a0
> [  183.211216]  [<ffffffff81632ede>] do_page_fault+0xe/0x10
> [  183.293705]  [<ffffffff8162f518>] page_fault+0x28/0x30=20

Johannes, this looks like the thp migration memcg hookery gone bad,
could you have a look at this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
