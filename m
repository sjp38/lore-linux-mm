Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7263F6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 04:31:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so11461685lfi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 01:31:24 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id 201si2843396wms.49.2016.07.11.01.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 01:31:22 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Jul 2016 10:31:22 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: [4.7.0rc6] Page Allocation Failures with dm-crypt
In-Reply-To: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
Message-ID: <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dm-devel@redhat.com, linux-kernel@vger.kernel.org

Hello,

I made a few more tests and here my observations:

- kernels 4.4.8 and 4.5.5 show the same behavior

- the moment dd starts, memory usage spikes rapidly and within a just
   a few seconds has filled up all 32 GiB of RAM

- dd w/ direct i/o works just fine

- mkfs.ext4 unfortunately shows the same behavior as dd w/o direct i/o
   and such makes creation of an ext4 fs on dm-crypt a game of luck

   (much more exposed so with e2fsprogs 1.43.1)

I am kind of puzzled that this bug has seemingly gone so long unnoticed
since it is rather severe and makes dm-crypt unusable to a certain 
degree
for fs encryption (or at least the initial creation of the fs). Am I
missing something here or doing something terribly stupid?

With Kind Regards from Germany
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
