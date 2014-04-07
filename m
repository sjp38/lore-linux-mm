Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 13E166B003B
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 13:58:22 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so7072525wgg.1
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 10:58:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cy3si5559704wib.39.2014.04.07.10.58.20
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 10:58:20 -0700 (PDT)
Date: Mon, 07 Apr 2014 13:57:48 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5342e73c.035eb40a.1e1c.ffffacb2SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1396462128-32626-2-git-send-email-lcapitulino@redhat.com>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
 <1396462128-32626-2-git-send-email-lcapitulino@redhat.com>
Subject: Re: [PATCH 1/4] hugetlb: add hstate_is_gigantic()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lcapitulino@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Wed, Apr 02, 2014 at 02:08:45PM -0400, Luiz Capitulino wrote:
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Maybe some description should be desirable even if it's a trivial cleanup.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
