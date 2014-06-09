Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 108546B00C4
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 19:35:10 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so9732296qgd.10
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:35:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q8si25541883qai.25.2014.06.09.16.35.09
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 16:35:09 -0700 (PDT)
Date: Mon, 9 Jun 2014 19:34:59 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: rb_erase oops.
Message-ID: <20140609233459.GA26101@redhat.com>
References: <20140609223028.GA13109@redhat.com>
 <CA+55aFw8MzKeNFPO+CgxyBcH-VZP4Q0Te+-Ue+r3-NNBjZ=mFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw8MzKeNFPO+CgxyBcH-VZP4Q0Te+-Ue+r3-NNBjZ=mFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jun 09, 2014 at 04:30:21PM -0700, Linus Torvalds wrote:
 > On Mon, Jun 9, 2014 at 3:30 PM, Dave Jones <davej@redhat.com> wrote:
 > >
 > > Oops: 0000 [#1] PREEMPT SMP
 > 
 > Dave, for some reason your oops is missing the first line. There
 > should have been something like
 > 
 >  "Unable to handle kernel NULL pointer access at 00000001"
 > 
 > or something.

For some reason, that line never made it over usb-serial.

[56274.041989] trinity-c22 (7025) used greatest stack depth: 9440 bytes left
[77373.915561] Oops: 0000 [#1] PREEMPT SMP

Weird.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
