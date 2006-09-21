Date: Wed, 20 Sep 2006 18:08:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] shared page table for hugetlb page - v2
Message-Id: <20060920180825.1c1ad6ae.akpm@osdl.org>
In-Reply-To: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
References: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006 17:57:33 -0700
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:

> Following up with the work on shared page table, here is a re-post of
> shared page table for hugetlb memory.

Is that actually useful?  With one single pagetable page controlling,
say, 4GB of hugepage memory, I'm surprised that there's much point in
trying to optimise it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
