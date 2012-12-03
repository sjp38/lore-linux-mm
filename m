Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id B2D816B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 02:38:26 -0500 (EST)
Date: Mon, 3 Dec 2012 16:38:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram, OOM, and speed of allocation
Message-ID: <20121203073824.GB4569@blaptop>
References: <CAA25o9S5zpH_No+xgYuFSAKSRkQ=19Vf_aLgO1UWiajQxtjrpg@mail.gmail.com>
 <CAA25o9TnmSqBe48EN+9E6E8EiSzKf275AUaAijdk3wxg6QV2kQ@mail.gmail.com>
 <CAA25o9RiNfwtoeMBk=PLg-X_2wPSHuYLztONw1KToeOx9pUHGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9RiNfwtoeMBk=PLg-X_2wPSHuYLztONw1KToeOx9pUHGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>

Hi Luigi,

It's another patch without dependency with previous my patches.
You can control /proc/sys/vm/swappiness up to 200(which means VM reclaimer
can reclaim only anonymous pages) so I hope it makes swap device full while
file-backed page(ie, code pages) are protected from eviction.

I hope this patch removes your hacky min_filelist_kbytes.
Could you try this and send feedback?
