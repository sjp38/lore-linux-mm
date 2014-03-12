Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 424C46B00AC
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:23:00 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id w7so6592625lbi.20
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:22:59 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id am3si25593460lac.172.2014.03.12.07.22.57
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 07:22:57 -0700 (PDT)
Date: Wed, 12 Mar 2014 16:22:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 0/2] mm: map few pages around fault address if they are
 in page cache
Message-ID: <20140312142247.GA11013@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 01:28:22PM -0800, Linus Torvalds wrote:
>  (a) could you test this on a couple of different architectures?


Here's data from 4-socket Westmere. The advantage of faultaround is not that
obvious here.

FAULT_AROUND_ORDER              baseline        2               4               6

Linux build (make -j40)
minor-faults                    297,626,681     245,934,795     227,800,211     221,052,532
time, seconds                   293.4322        291.4602        292.9198        295.2355

Linux rebuild (make -j40)
minor-faults                    5,903,936       3,802,148       3,018,728       2,735,602
time, seconds                   41.5657         41.0301         40.7621         41.1161

Git test suite
minor-faults                    171,314,056     109,187,718     81,955,503      70,172,157
time, seconds                   223.2327        220.2623        223.8355        231.7843

I don't have time to test on Haswell now. Probably later.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
