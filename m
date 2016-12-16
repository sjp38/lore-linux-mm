Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5819F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 22:54:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so156896372pgd.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 19:54:36 -0800 (PST)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id m136si5450013pga.237.2016.12.15.19.54.34
        for <linux-mm@kvack.org>;
        Thu, 15 Dec 2016 19:54:35 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161104193626.GU4611@redhat.com> <1805f956-1777-471c-1401-46c984189c88@oracle.com> <20161116182809.GC26185@redhat.com> <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com> <20161117154031.GA10229@redhat.com> <718434af-d279-445d-e210-201bf02f434f@oracle.com> <20161118000527.GB10229@redhat.com> <c9350efa-ca79-c514-0305-22c90fdbb0df@oracle.com> <1b60f0b3-835f-92d6-33e2-e7aaab3209cc@oracle.com> <019d01d24554$38e7f220$aab7d660$@alibaba-inc.com> <20161215190242.GC4909@redhat.com>
In-Reply-To: <20161215190242.GC4909@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Fri, 16 Dec 2016 11:54:21 +0800
Message-ID: <04c301d25750$15fdcb00$41f96100$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>
Cc: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Friday, December 16, 2016 3:03 AM Andrea Arcangeli wrote:
 > I already applied Mark's patch that clears the page private flag in
> the error path. 
> 
Glad to hear it:)

Happy Christmas Andrea.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
