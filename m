Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 204FE6B0070
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:09:01 -0400 (EDT)
Message-ID: <4FEDFD0F.7070207@redhat.com>
Date: Fri, 29 Jun 2012 15:07:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 21/40] autonuma: avoid CFS select_task_rq_fair to return
 -1
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>  <1340888180-15355-22-git-send-email-aarcange@redhat.com>  <4FEDFAB1.8050305@redhat.com> <1340996749.28750.125.camel@twins>
In-Reply-To: <1340996749.28750.125.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/29/2012 03:05 PM, Peter Zijlstra wrote:
> On Fri, 2012-06-29 at 14:57 -0400, Rik van Riel wrote:
>> Either this is a scheduler bugfix, in which case you
>> are better off submitting it separately and reducing
>> the size of your autonuma patch queue, or this is a
>> behaviour change in the scheduler that needs better
>> arguments than a 1-line changelog.
>
> I've only said this like 2 or 3 times.. :/

I'll keep saying it until Andrea has fixed it :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
