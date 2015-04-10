Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 21A9B6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 04:08:59 -0400 (EDT)
Received: by widdi4 with SMTP id di4so119142629wid.0
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 01:08:58 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id ez17si1905114wjc.157.2015.04.10.01.08.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Apr 2015 01:08:57 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 10 Apr 2015 09:08:56 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id CAA8F1B08061
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 09:09:25 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3A88rEM3670310
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 08:08:53 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3A88q21020722
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 02:08:53 -0600
Date: Fri, 10 Apr 2015 10:08:49 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
Message-ID: <20150410100849.56b9d677@thinkpad>
In-Reply-To: <alpine.DEB.2.10.1504091235500.11370@chino.kir.corp.google.com>
References: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
	<alpine.DEB.2.10.1504091235500.11370@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Jiri Slaby <jslaby@suse.cz>

On Thu, 9 Apr 2015 12:41:47 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 9 Apr 2015, Gerald Schaefer wrote:
> 
> > commit 61f77eda "mm/hugetlb: reduce arch dependent code around
> > follow_huge_*" broke follow_huge_pmd() on s390, where pmd and pte
> > layout differ and using pte_page() on a huge pmd will return wrong
> > results. Using pmd_page() instead fixes this.
> > 
> > All architectures that were touched by commit 61f77eda have
> > pmd_page() defined, so this should not break anything on other
> > architectures.
> > 
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > Cc: stable@vger.kernel.org # v3.12
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> I'm not sure where the stable cc came from, though: commit 61f77eda
> makes s390 use a generic version of follow_huge_pmd() and that
> generic version is buggy for s930 because of commit e66f17ff7177
> ("mm/hugetlb: take page table lock in follow_huge_pmd()").  Both of
> those are 4.0 material, though, so why is this needed for stable 3.12?

Both commits 61f77eda and e66f17ff already made it into the 3.12 stable
tree, probably because of SLES 12 (actually that's how I noticed them).

But I guess I screwed up the stable CC, stable@vger.kernel.org.#.v3.12
somehow doesn't look right, not sure if the CC in the patch header
suffices. Looks like Jiri Slaby added the patches to 3.12, putting him
on CC now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
