Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 93D3C6B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 15:58:15 -0400 (EDT)
Message-ID: <52336E41.40307@intel.com>
Date: Fri, 13 Sep 2013 12:57:53 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/9] mm: implement split page table lock for PMD level
References: <20130910074748.GA2971@gmail.com> <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com> <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/13/2013 06:06 AM, Kirill A. Shutemov wrote:
> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> +	boolean
> +
> +config SPLIT_PMD_PTLOCK_CPUS
> +	int
> +	# hugetlb hasn't converted to split locking yet
> +	default "999999" if HUGETLB_PAGE
> +	default "32" if ARCH_ENABLE_SPLIT_PMD_PTLOCK
> +	default "999999"

Is there a reason we should have separate config knobs for this from
SPLIT_PTLOCK_CPUS?  Seem a bit silly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
