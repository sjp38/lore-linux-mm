Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C834B6B0033
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 10:52:17 -0400 (EDT)
Date: Fri, 13 Sep 2013 16:52:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] mm: implement split page table lock for PMD level
Message-ID: <20130913145204.GG21832@twins.programming.kicks-ass.net>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
 <20130913132435.GD21832@twins.programming.kicks-ass.net>
 <20130913142513.A62ABE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130913142513.A62ABE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Sep 13, 2013 at 05:25:13PM +0300, Kirill A. Shutemov wrote:
> Peter Zijlstra wrote:
> > On Fri, Sep 13, 2013 at 04:06:15PM +0300, Kirill A. Shutemov wrote:
> > > The basic idea is the same as with PTE level: the lock is embedded into
> > > struct page of table's page.
> > > 
> > > Split pmd page table lock only makes sense on big machines.
> > > Let's say >= 32 CPUs for now.
> > 
> > Why is this? Couldn't I generate the same amount of contention on PMD
> > level as I can on PTE level in the THP case?
> 
> Hm. You are right. You just need more memory for that.
> Do you want it to be "4" too?

Well, I would drop your patch-1 and use the same config var.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
