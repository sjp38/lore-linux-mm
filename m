Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C46CC6B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 14:48:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so161190046pfy.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 11:48:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id i1si18981799pfb.54.2016.05.12.11.48.22
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 11:48:22 -0700 (PDT)
Date: Thu, 12 May 2016 14:48:19 -0400
From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Subject: Re: [1/1] mm: thp: calculate the mapcount correctly for THP pages during WP faults
Message-ID: <20160512184811.GA5692@phlsvsds.ph.intel.com>
References: <1463070742-18401-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1463070742-18401-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Luick, Dean" <dean.luick@intel.com>

>
>Reviewed-by: "Kirill A. Shutemov" <kirill@shutemov.name>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>

Andrea,

Perhaps add a V<n> in the subject for subsequent submissions as well as
version change control in email after the ---.

I happened to know the differences, but others might not.

This patch also solves the >= 4.5-rc1 IB user memory registration thp bug
that results in memory corruption!

Reviewed-by: Dean Luick <dean.luick@intel.com>
Tested-by: Mike Marciniszyn <mike.marciniszyn@intel.com>
Tested-by: Josh Collier <josh.d.collier@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
