Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 844536B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:18:32 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so14275666pab.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:18:32 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id qq9si11138210pbb.13.2015.06.18.05.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 05:18:31 -0700 (PDT)
Received: by paceq1 with SMTP id eq1so35915549pac.3
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:18:31 -0700 (PDT)
Date: Thu, 18 Jun 2015 21:17:46 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH v3 0/7] introduce automatic pool compaction
Message-ID: <20150618121746.GB518@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Minchan, FYI,

I re-done the test (untouched almost_empty waterline).


		Kernel log
test started [  788.064886]
test ended   [ 4025.914190]

test (doing `cp' in parallel):
(a) for i in {1..X}; do cp -R ~/git .; sync; rm -fr git/; done

# compiled kernel, with object files. 2.2G
(b) for i in {1..X}; do cp -R ~/linux/ .; sync; rm -fr linux/; done

(c) for i in {1..X}; do cp -R ~/glibc/ .; sync; rm -fr glibc/; done


Minimal si_meminfo(&si)->si.freeram observed on the system was: 6390


cat /sys/block/zram0/stat
   31253        0   250024      316 12281689        0 98253512   141263        0   141590   141763

cat /sys/block/zram0/mm_stat
3183374336 2105262569 2140762112        0 2821394432     1864   358173


The results are:

compaction nr:2335 (full:953 part:60956)

ratio: 0.01539   (~1.53% of classes were fully compacted)


More or less same numbers.


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
