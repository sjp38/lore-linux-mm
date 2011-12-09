Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 200556B005A
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 15:44:53 -0500 (EST)
Received: by qao25 with SMTP id 25so2960031qao.14
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 12:44:52 -0800 (PST)
Message-ID: <4EE27345.90003@gmail.com>
Date: Fri, 09 Dec 2011 15:44:53 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: simplify find_vma_prev
References: <1323461345-12805-1-git-send-email-kosaki.motohiro@gmail.com> <20111209122406.11f9e31a.akpm@linux-foundation.org>
In-Reply-To: <20111209122406.11f9e31a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

> This changes the (undocumented, naturally) interface in disturbing ways.
>
> Currently, *pprev will always be written to.  With this change, *pprev
> will only be written to if find_vma_prev() returns non-NULL.
>
> Looking through the code, this is mostly benign.  But it will cause the
> CONFIG_STACK_GROWSUP version of find_extend_vma() to use an
> uninitialised stack slot in ways which surely will crash the kernel.

Weird.


> So please have a think about that and fix it up.  And please add
> documentation for find_vma_prev()'s interface so we don't break it next
> time.

Sure thing. Thank you for good spotting!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
