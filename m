Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 188C76B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 07:17:44 -0400 (EDT)
Message-ID: <50321CD3.5050501@redhat.com>
Date: Mon, 20 Aug 2012 07:17:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Repeated fork() causes SLAB to grow without bound
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu> <502F100A.1080401@redhat.com> <alpine.LSU.2.00.1208200032450.24855@eggly.anvils> <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
In-Reply-To: <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/20/2012 05:39 AM, Michel Lespinasse wrote:

> I would still prefer if we could just remove the anon_vma_chain stuff, though.

If only we could.

That simply replaces a medium issue at fork time, with the
potential for a catastrophic issue at page reclaim time,
in any workload with heavily forking server software.

Without the anon_vma_chains, we end up scanning every single
one of the child processes (and the parent) for every COWed
page, which can be a real issue when the VM runs into 1000
such pages, for 1000 child processes.

Unfortunately, we have seen this happen...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
