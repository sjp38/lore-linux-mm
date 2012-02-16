Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9018C6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:54:10 -0500 (EST)
Date: Wed, 15 Feb 2012 16:54:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] introduce pmd_to_pte_t()
Message-Id: <20120215165408.a111eefa.akpm@linux-foundation.org>
In-Reply-To: <1328716302-16871-6-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1328716302-16871-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed,  8 Feb 2012 10:51:41 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Casting pmd into pte_t to handle thp is strongly architecture dependent.
> This patch introduces a new function to separate this dependency from
> independent part.
> 
>
> ...
>
> --- 3.3-rc2.orig/include/asm-generic/pgtable.h
> +++ 3.3-rc2/include/asm-generic/pgtable.h
> @@ -434,6 +434,10 @@ static inline int pmd_trans_splitting(pmd_t pmd)
>  {
>  	return 0;
>  }
> +static inline pte_t pmd_to_pte_t(pmd_t *pmd)
> +{
> +	return 0;
> +}

This doesn't compile.

And I can't think of a sensible way of generating a stub for this
operation - if you have a pmd_t and want to convert it to a pte_t then
just convert it, dammit.  And there's no rationality behind making that
conversion unavailable or inoperative if CONFIG_TRANSPARENT_HUGEPAGE=n?

Shudder.  I'll drop the patch.  Rethink, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
