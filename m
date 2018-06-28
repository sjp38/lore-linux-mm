Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C395D6B0003
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 00:51:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o7-v6so1837838pgc.23
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 21:51:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t20-v6si5121621pga.21.2018.06.27.21.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 21:51:46 -0700 (PDT)
Date: Wed, 27 Jun 2018 21:51:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Message-Id: <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
In-Reply-To: <20180622035151.6676-1-ying.huang@intel.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Fri, 22 Jun 2018 11:51:30 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> This is the final step of THP (Transparent Huge Page) swap
> optimization.  After the first and second step, the splitting huge
> page is delayed from almost the first step of swapout to after swapout
> has been finished.  In this step, we avoid splitting THP for swapout
> and swapout/swapin the THP in one piece.

It's a tremendously good performance improvement.  It's also a
tremendously large patchset :(

And it depends upon your
mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch and
mm-fix-race-between-swapoff-and-mincore.patch, the first of which has
been floating about since February without adequate review.

I'll give this patchset a spin in -mm to see what happens and will come
back later to take a closer look.  But the best I can do at this time
is to hopefully cc some possible reviewers :)
