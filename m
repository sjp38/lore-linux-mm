Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id AAA0D6B0035
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 16:32:36 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id b15so47835eek.6
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 13:32:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g5si321553eew.105.2014.03.04.13.32.33
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 13:32:34 -0800 (PST)
Date: Tue, 04 Mar 2014 16:32:23 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53164672.05300f0a.3ff5.ffff9885SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5314F661.30202@oracle.com>
References: <53126861.7040107@oracle.com>
 <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5314E0CD.6070308@oracle.com>
 <5314F661.30202@oracle.com>
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

# sorry if duplicate message

On Mon, Mar 03, 2014 at 04:38:41PM -0500, Sasha Levin wrote:
> On 03/03/2014 03:06 PM, Sasha Levin wrote:
> >On 03/03/2014 12:02 AM, Naoya Horiguchi wrote:
> >>Hi Sasha,
> >>
> >>>>I can confirm that with this patch the lockdep issue is gone. However, the NULL deref in
> >>>>walk_pte_range() and the BUG at mm/hugemem.c:3580 still appear.
> >>I spotted the cause of this problem.
> >>Could you try testing if this patch fixes it?
> >
> >I'm seeing a different failure with this patch:
> 
> And the NULL deref still happens.

I don't yet find out the root reason why this issue remains.
So I tried to run trinity myself but the problem didn't reproduce.
(I did simply like "./trinity --group vm --dangerous" a few hours.)
Could you show more detail or tips about how the problem occurs?

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
