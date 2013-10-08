Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3731F6B003C
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 05:04:15 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so8283194pdj.8
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:04:14 -0700 (PDT)
Received: by mail-ea0-f175.google.com with SMTP id m14so3767280eaj.6
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:04:11 -0700 (PDT)
Date: Tue, 8 Oct 2013 11:04:08 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv5 00/11] split page table lock for PMD tables
Message-ID: <20131008090408.GF3295@gmail.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131007160907.3a4aca3e7eae404767ed3a8e@linux-foundation.org>
 <20131008084927.BC193E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008084927.BC193E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> > What must arch maintainers do to enable it?  Have you any particular 
> > suggestions, warnings etc to make their lives easier?
> 
> The last patch is a good illustration what need to be done. It's very 
> straight forward, I don't see any pitfalls.

Might make sense to stick that somewhere into Documentation/mm/, to make 
arch maintainers feel all warm and fuzzy if they look into enabling this 
feature on their architecture.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
