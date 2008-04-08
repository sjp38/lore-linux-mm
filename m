From: Nitin Gupta <nitingupta910@gmail.com>
Subject: [PATCH 0/3] compcache: compressed caching v2
Date: Tue, 8 Apr 2008 14:59:27 +0530
Message-ID: <200804081459.27382.nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757228AbYDHJl4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi All,

(This revision contains all changes suggested in initial review).

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
under memory pressure. For now, it has been tested on x86 and x86_64.

Thanks,
Nitin
