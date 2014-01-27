Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6176B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:04:25 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so7997453qae.24
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:04:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 6si9578024qgy.36.2014.01.27.13.04.23
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:04:23 -0800 (PST)
Date: Mon, 27 Jan 2014 16:04:13 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856653-v1nkcg1e-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-7-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-7-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 6/8] mm, hugetlb: remove vma_has_reserves
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:24PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> vma_has_reserves() can be substituted by using return value of
> vma_needs_reservation(). If chg returned by vma_needs_reservation()
> is 0, it means that vma has reserves. Otherwise, it means that vma don't
> have reserves and need a hugepage outside of reserve pool. This definition
> is perfectly same as vma_has_reserves(), so remove vma_has_reserves().

I'm concerned that this patch doesn't work when VM_NORESERVE is set.
vma_needs_reservation() doesn't check VM_NORESERVE and this patch changes
dequeue_huge_page_vma() not to check it. So no one seems to check it any more.
It would be nice if you add some comment about the justification in changelog.
Does the testcase attached in commit af0ed73e699b still pass with this patch?
(I'm not sure it's covered in libhugetlbfs test suite.)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
