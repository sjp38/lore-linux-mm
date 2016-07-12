Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6478B6B026E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:06:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so5742549lfg.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 01:06:05 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id q3si1893229wma.34.2016.07.12.01.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 01:06:04 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jul 2016 10:06:03 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: [dm-devel] [4.7.0rc6] Page Allocation Failures with dm-crypt
In-Reply-To: <2786d2f951a90eb00502096aca71e05b@mail.ud19.udmedia.de>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
 <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
 <20160711131818.GA28102@redhat.com> <20160711133051.GA28308@redhat.com>
 <2786d2f951a90eb00502096aca71e05b@mail.ud19.udmedia.de>
Message-ID: <e27c7f1c4a5fc42960c6eddda323ae37@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

Hello Mike...

It (at least) seems like that the fact that this is a Intel Rapid
Storage RAID10 does play a role after all.

I did several tests this morning, after I finally managed to get
another disk hooked up via USB3 (the best I could do for now).

I tried dm-crypt w/ a single partition and with a Linux s/w RAID1 and
RAID10. Unfortunately the RAID tests were done with several partitions
that were on the same disk since that is all I have for testing.

No matter what I did, I could not get to the point where all memory
got exhausted... not even close.

So with all tests I have done over the last couple of days, the only
one were I could always hit this issue was with my original RAID10
that is a Intel Rapid Storage RAID -- and hooked up to the internal
SATA3 ports instead of the USB3 port (which I hope makes no huge
difference for this issue).

I will post to the linux raid list in a few moments and cc' this list
as well.

Thanks again for the help thus far,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
