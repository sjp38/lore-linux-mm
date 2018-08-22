Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 739326B24A0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:41:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v21-v6so1828172wrc.2
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 06:41:58 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e8-v6si1272261wrp.36.2018.08.22.06.41.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 22 Aug 2018 06:41:57 -0700 (PDT)
Date: Wed, 22 Aug 2018 15:41:52 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: How to profile 160 ms spent in
 `add_highpages_with_active_regions()`?
In-Reply-To: <4f8d0de0-e9f1-e3cd-1f94-e95e6fa47ecf@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1808221539190.1652@nanos.tec.linutronix.de>
References: <d5a65984-36a7-15d8-b04a-461d0f53d36d@molgen.mpg.de> <5e5a39f4-1b91-c877-1368-0946160ef4be@molgen.mpg.de> <4f8d0de0-e9f1-e3cd-1f94-e95e6fa47ecf@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-908373953-1534945315=:1652"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>
Cc: linux-mm@kvack.org, x86@kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-908373953-1534945315=:1652
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Wed, 22 Aug 2018, Paul Menzel wrote:
> Am 21.08.2018 um 11:37 schrieb Paul Menzel:
> > [Removed non-working Pavel Tatashin <pasha.tatashin@oracle.com>]
> 
> So a??freea??inga?? pfn = 225278 to e_pfn = 818492 in the for loop takes 160 ms.

That's 593214 pages and each one takes about 270ns. I don't see much
optimization potential with that.

32bit and highmem sucks ...
--8323329-908373953-1534945315=:1652--
