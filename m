Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CE72E6B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:27:35 -0400 (EDT)
Message-ID: <4FFF40D8.10000@redhat.com>
Date: Thu, 12 Jul 2012 17:25:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 28/40] autonuma: make khugepaged pte_numa aware
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-29-git-send-email-aarcange@redhat.com> <4FF12284.4040109@redhat.com> <20120712185031.GN20382@redhat.com>
In-Reply-To: <20120712185031.GN20382@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 07/12/2012 02:50 PM, Andrea Arcangeli wrote:
> On Mon, Jul 02, 2012 at 12:24:36AM -0400, Rik van Riel wrote:
>> On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
>>> If any of the ptes that khugepaged is collapsing was a pte_numa, the
>>> resulting trans huge pmd will be a pmd_numa too.
>>
>> Why?
>>
>> If some of the ptes already got faulted in and made really
>> resident again, why do you want to incur a new NUMA fault
>> on the newly collapsed hugepage?
>
> If we don't set pmd_numa on the collapsed hugepage, the result is that
> we'll understimate the thread NUMA affinity to the node where the
> hugepage is located (mm affinity is recorded independently by the NUMA
> hinting page faults).
>
> If it's better or worse I guess depends on luck, we just lose
> information.

Fair enough.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
