Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C06E16B003C
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 13:58:28 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so900955eek.38
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 10:58:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id eo9si2757772wid.41.2014.04.07.10.58.26
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 10:58:26 -0700 (PDT)
Date: Mon, 07 Apr 2014 13:58:15 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5342e742.490cb50a.5bf3.ffffa8bbSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1396462128-32626-4-git-send-email-lcapitulino@redhat.com>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
 <1396462128-32626-4-git-send-email-lcapitulino@redhat.com>
Subject: Re: [PATCH 3/4] hugetlb: move helpers up in the file
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lcapitulino@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Wed, Apr 02, 2014 at 02:08:47PM -0400, Luiz Capitulino wrote:
> Next commit will add new code which will want to call the
> for_each_node_mask_to_alloc() macro. Move it, its buddy
> for_each_node_mask_to_free() and their dependencies up in the file so
> the new code can use them. This is just code movement, no logic change.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
