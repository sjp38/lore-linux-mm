Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C834A680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:20:25 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e65so54407889pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:20:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e3si7416164pas.149.2016.01.11.18.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 18:20:25 -0800 (PST)
Date: Mon, 11 Jan 2016 18:20:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
Message-Id: <20160111182010.bc4e171b.akpm@linux-foundation.org>
In-Reply-To: <569458AB.5000102@oracle.com>
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
	<20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
	<56943D00.7090405@oracle.com>
	<20160111162931.0bea916e.akpm@linux-foundation.org>
	<569458AB.5000102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, 11 Jan 2016 17:36:43 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> > 
> > I'll mark this patch as "pending, awaiting Mike's go-ahead".
> > 
> 
> When this patch was originally submitted, bugs were discovered in the
> hugetlb_vmdelete_list routine.  So, the patch "Fix bugs in
> hugetlb_vmtruncate_list" was created.
> 
> I have retested the changes in this patch specifically dealing with
> page fault/hole punch race on top of the new hugetlb_vmtruncate_list
> routine.  Everything looks good.
> 
> How would you like to proceed with the patch?
> - Should I create a series with the hugetlb_vmtruncate_list split out?
> - Should I respin with hugetlb_vmtruncate_list patch applied?
> 
> Just let me know what is easiest/best for you.

If you're saying that
http://ozlabs.org/~akpm/mmots/broken-out/mm-mempolicy-skip-non-migratable-vmas-when-setting-mpol_mf_lazy.patch
and
http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlbfs-unmap-pages-if-page-fault-raced-with-hole-punch.patch
are the final everything-works versions then we're all good to go now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
