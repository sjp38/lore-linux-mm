Received: by wa-out-1112.google.com with SMTP id m33so2962407wag.8
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:04:52 -0700 (PDT)
From: Nitin Gupta <nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Subject: [PATCH 0/6]: compcache: Compressed Caching
Date: Mon, 24 Mar 2008 20:30:05 +0530
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803242030.05997.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

(sending to lkml since I didn't get any reply at linux-mm).

This implements a RAM based block device which acts as swap disk.
Pages swapped to this disk are compressed and stored in memory itself.
This allows more applications to fit in given amount of memory. This is
especially useful for embedded devices, OLPC and small desktops
(aka virtual machines).

Project home: http://code.google.com/p/compcache/

It consists of following components:
- compcache.ko: Creates RAM based block device
- tlsf.ko: Two Level Segregate Fit (TLSF) allocator
- LZO de/compressor: (Already in mainline)

Project home contains some performance numbers for TLSF and LZO.
For general desktop use, this is giving *significant* performance gain
under memory pressure. For now, it has been tested only on x86.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
