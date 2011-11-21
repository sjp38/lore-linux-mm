Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D13C46B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 03:12:22 -0500 (EST)
Date: Mon, 21 Nov 2011 09:12:11 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] hugetlb: release pages in the error path of hugetlb_cow()
Message-ID: <20111121081152.GA1771@redhat.com>
References: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 09:01:20PM +0800, Hillf Danton wrote:
> If fail to prepare anon_vma, {new, old}_page should be released, or they will
> escape the track and/or control of memory management.
> 
> Thanks
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
