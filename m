Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id F193F6B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:58:18 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id h184-v6so7089351wmf.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:58:18 -0800 (PST)
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id i30-v6si31919706wri.305.2018.11.05.07.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Nov 2018 07:58:17 -0800 (PST)
Date: Mon, 5 Nov 2018 16:58:15 +0100
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: Creating compressed backing_store as swapfile
Message-ID: <20181105155815.i654i5ctmfpqhggj@angband.pl>
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu.ping@gmail.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On Mon, Nov 05, 2018 at 08:31:46PM +0530, Pintu Agarwal wrote:
> Hi,
> 
> I have one requirement:
> I wanted to have a swapfile (64MB to 256MB) on my system.
> But I wanted the data to be compressed and stored on the disk in my swapfile.
> [Similar to zram, but compressed data should be moved to disk, instead of RAM].
> 
> Note: I wanted to optimize RAM space, so performance is not important
> right now for our requirement.
> 
> So, what are the options available, to perform this in 4.x kernel version.
> My Kernel: 4.9.x
> Board: any - (arm64 mostly).
> 
> As I know, following are the choices:
> 1) ZRAM: But it compresses and store data in RAM itself
> 2) frontswap + zswap : Didn't explore much on this, not sure if this
> is helpful for our case.
> 3) Manually creating swapfile: but how to compress it ?
> 4) Any other options ?

Loop device on any filesystem that can compress (such as btrfs)?  The
performance would suck, though -- besides the indirection of loop, btrfs
compresses in blocks of 128KB while swap wants 4KB writes.  Other similar
option is qemu-nbd -- it can use compressed disk images and expose them to a
(local) nbd client.


Meow!
-- 
ac?aGBP'a  3/4 a >>ac?aGBP|a ? Have you heard of the Amber Road?  For thousands of years, the
aGBP 3/4 a ?ac?a ?a ?aGBP?a!? Romans and co valued amber, hauled through the Europe over the
ac?a!?a ?a .a ?a ?a ? mountains and along the Vistula, from GdaA?sk.  To where it came
a ?a 3aGBP?a ?a ?a ?a ? together with silk (judging by today's amber stalls).
