Received: by wa-out-1112.google.com with SMTP id j37so419255waf.22
        for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:13:49 -0800 (PST)
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
From: Eric Rannaud <eric.rannaud@gmail.com>
In-Reply-To: <23027.1226443216@turing-police.cc.vt.edu>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
	 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
	 <1226409701-14831-4-git-send-email-ieidus@redhat.com>
	 <20081111150345.7fff8ff2@bike.lwn.net>
	 <23027.1226443216@turing-police.cc.vt.edu>
Content-Type: text/plain
Date: Wed, 12 Nov 2008 22:13:47 -0800
Message-Id: <1226556827.13670.54.camel@nc050>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Jonathan Corbet <corbet@lwn.net>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-11 at 17:40 -0500, Valdis.Kletnieks@vt.edu wrote: 
> On Tue, 11 Nov 2008 15:03:45 MST, Jonathan Corbet said:
> Seems reasonably sane to me - only doing the first 128 bytes rather than
> a full 4K page is some 32 times faster.  Yes, you'll have the *occasional*
> case where two pages were identical for 128 bytes but then differed, which is
> why there's buckets.  But the vast majority of the time, at least one bit
> will be different in the first part.

In the same spirit, computing a CRC32 instead of a SHA1 would probably
be faster as well (faster to compute, and faster to compare the
digests). The increased rate of collision should be negligible.

Also, the upcoming SSE4.2 (Core i7) has a CRC32 instruction. (Support is
already in the kernel: arch/x86/crypto/crc32c-intel.c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
