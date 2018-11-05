Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 522836B0010
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:30 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id a80-v6so12435716itd.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n1sor48044310itk.30.2018.11.05.08.56.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 08:56:29 -0800 (PST)
Subject: Re: Creating compressed backing_store as swapfile
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
 <20181105155815.i654i5ctmfpqhggj@angband.pl>
 <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
 <42594.1541434463@turing-police.cc.vt.edu>
 <6a1f57b6-503c-48a2-689b-3c321cd6d29f@gmail.com>
 <83467.1541436836@turing-police.cc.vt.edu>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <20fe7145-8426-c67d-2ab2-258ec5717966@gmail.com>
Date: Mon, 5 Nov 2018 11:55:58 -0500
MIME-Version: 1.0
In-Reply-To: <83467.1541436836@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: valdis.kletnieks@vt.edu
Cc: Adam Borowski <kilobyte@angband.pl>, Pintu Agarwal <pintu.ping@gmail.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On 11/5/2018 11:53 AM, valdis.kletnieks@vt.edu wrote:
> On Mon, 05 Nov 2018 11:28:49 -0500, "Austin S. Hemmelgarn" said:
> 
>> Also, it's probably worth noting that BTRFS doesn't need to decompress
>> the entire file to read or write blocks in the middle, it splits the
>> file into 128k blocks and compresses each of those independent of the
>> others, so it can just decompress the 128k block that holds the actual
>> block that's needed.
> 
> Presumably it does something sane with block allocation for the now-compressed
> 128K that's presumably much smaller.  Also, that limits the damage from writing to
> the middle of a compression unit....
> 
> That *does* however increase the memory requirement - you can OOM or
> deadlock if your read/write from the swap needs an additional 128K for the
> compression buffer at an inconvenient time...
> 
Indeed, and I can't really comment on how it might behave under those 
circumstances (the systems I did the testing on never saw memory 
pressure quite _that_ bad, and I had them set up to swap things out 
pretty early and really aggressively).
