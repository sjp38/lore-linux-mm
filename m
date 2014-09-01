Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id C40A66B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 00:41:32 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id x13so5007152qcv.9
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 21:41:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g8si9416907qaq.10.2014.08.31.21.41.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Aug 2014 21:41:32 -0700 (PDT)
Date: Mon, 1 Sep 2014 00:08:45 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/6] hugepage migration fixes (v3)
Message-ID: <20140901040845.GA30158@nhori>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87tx4sk7bs.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tx4sk7bs.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Sun, Aug 31, 2014 at 08:27:35AM -0700, Andi Kleen wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > This is the ver.3 of hugepage migration fix patchset.
> 
> I wonder how far we are away from support THP migration with the
> standard migrate_pages() syscall?

I don't think that we are very far from this because we can borrow
some code from migrate_misplaced_transhuge_page(), and the experience
in hugetlb migration will be also helpful.
The difficulties are rather in integrating thp support in the existing
migrate code which is already very complicated, so careful code-reading
and testing is necessary.
This topic was in my agenda for long, but no highlight at this point.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
