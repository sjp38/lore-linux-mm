From: Dave Hansen <dave@sr71.net>
Subject: Re: [PATCH -mm] mincore: apply page table walker on do_mincore()
 (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
Date: Tue, 03 Jun 2014 08:59:45 -0700
Message-ID: <538DF0F1.5070104@sr71.net>
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net> <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
List-Id: linux-mm.kvack.org

On 06/02/2014 11:18 PM, Naoya Horiguchi wrote:
> +	/*
> +	 * Huge pages are always in RAM for now, but
> +	 * theoretically it needs to be checked.
> +	 */
> +	present = pte && !huge_pte_none(huge_ptep_get(pte));
> +	for (; addr != end; vec++, addr += PAGE_SIZE)
> +		*vec = present;
> +	cond_resched();
> +	walk->private += (end - addr) >> PAGE_SHIFT;

That comment is bogus, fwiw.  Huge pages are demand-faulted and it's
quite possible that they are not present.
