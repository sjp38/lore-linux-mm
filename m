Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id C88B76B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:02:00 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id h129so3761160vsd.22
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:02:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x6sor22629158uao.54.2018.11.05.07.01.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 07:01:59 -0800 (PST)
MIME-Version: 1.0
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Mon, 5 Nov 2018 20:31:46 +0530
Message-ID: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
Subject: Creating compressed backing_store as swapfile
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

Hi,

I have one requirement:
I wanted to have a swapfile (64MB to 256MB) on my system.
But I wanted the data to be compressed and stored on the disk in my swapfile.
[Similar to zram, but compressed data should be moved to disk, instead of RAM].

Note: I wanted to optimize RAM space, so performance is not important
right now for our requirement.

So, what are the options available, to perform this in 4.x kernel version.
My Kernel: 4.9.x
Board: any - (arm64 mostly).

As I know, following are the choices:
1) ZRAM: But it compresses and store data in RAM itself
2) frontswap + zswap : Didn't explore much on this, not sure if this
is helpful for our case.
3) Manually creating swapfile: but how to compress it ?
4) Any other options ?


Thanks,
Pintu
