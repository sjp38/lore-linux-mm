Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B56776B0033
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 10:25:23 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130913132435.GD21832@twins.programming.kicks-ass.net>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
 <20130913132435.GD21832@twins.programming.kicks-ass.net>
Subject: Re: [PATCH 8/9] mm: implement split page table lock for PMD level
Content-Transfer-Encoding: 7bit
Message-Id: <20130913142513.A62ABE0090@blue.fi.intel.com>
Date: Fri, 13 Sep 2013 17:25:13 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Peter Zijlstra wrote:
> On Fri, Sep 13, 2013 at 04:06:15PM +0300, Kirill A. Shutemov wrote:
> > The basic idea is the same as with PTE level: the lock is embedded into
> > struct page of table's page.
> > 
> > Split pmd page table lock only makes sense on big machines.
> > Let's say >= 32 CPUs for now.
> 
> Why is this? Couldn't I generate the same amount of contention on PMD
> level as I can on PTE level in the THP case?

Hm. You are right. You just need more memory for that.
Do you want it to be "4" too?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
