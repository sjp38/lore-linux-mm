Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 368206B002B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 04:55:19 -0400 (EDT)
Message-ID: <503C86DC.3040705@mellanox.com>
Date: Tue, 28 Aug 2012 11:52:44 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: Move the tlb flushing into free_pgtables
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>  <1345975899-2236-3-git-send-email-haggaie@mellanox.com> <1346041154.2296.1.camel@laptop>
In-Reply-To: <1346041154.2296.1.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Christoph Lameter <clameter@sgi.com>

On 27/08/2012 07:19, Peter Zijlstra wrote:
> On Sun, 2012-08-26 at 13:11 +0300, Haggai Eran wrote:
>> The conversion of the locks taken for reverse map scanning would
>> require taking sleeping locks in free_pgtables() and we cannot sleep
>> while gathering pages for a tlb flush. 
> We can.
>
After further reading I tend to agree. We can drop this patch and patch
number 3 then and focus on the first patch in this set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
