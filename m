Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id DFAD96B003D
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 13:58:30 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so7246582wes.11
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 10:58:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cj5si6558357wjb.74.2014.04.07.10.58.28
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 10:58:29 -0700 (PDT)
Date: Mon, 07 Apr 2014 13:58:05 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5342e745.255cc20a.01f2.680fSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1396462128-32626-3-git-send-email-lcapitulino@redhat.com>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
 <1396462128-32626-3-git-send-email-lcapitulino@redhat.com>
Subject: Re: [PATCH 2/4] hugetlb: update_and_free_page(): don't clear
 PG_reserved bit
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lcapitulino@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Wed, Apr 02, 2014 at 02:08:46PM -0400, Luiz Capitulino wrote:
> Hugepages pages never get the PG_reserved bit set, so don't clear it. But
> add a warning just in case.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
