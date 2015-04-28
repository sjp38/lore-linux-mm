Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2C46B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:16:05 -0400 (EDT)
Received: by wizk4 with SMTP id k4so158072648wiz.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:16:04 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id k6si20316901wiz.1.2015.04.28.15.16.03
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 15:16:04 -0700 (PDT)
Date: Wed, 29 Apr 2015 01:15:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
Message-ID: <20150428221553.GA5770@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Apr 28, 2015 at 01:42:10PM -0700, Andy Lutomirski wrote:
> At some point, I'd like to implement PCID on x86 (if no one beats me
> to it, and this is a low priority for me), which will allow us to skip
> expensive TLB flushes while context switching.  I have no idea whether
> ARM can do something similar.

I talked with Dave about implementing PCID and he thinks that it will be
net loss. TLB entries will live longer and it means we would need to trigger
more IPIs to flash them out when we have to. Cost of IPIs will be higher
than benifit from hot TLB after context switch.

Do you have different expectations?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
