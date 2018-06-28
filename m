Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302B06B0003
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:03:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x25-v6so2451015pfn.21
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:03:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y186-v6si5532917pgb.395.2018.06.28.02.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Jun 2018 02:03:03 -0700 (PDT)
Date: Thu, 28 Jun 2018 02:03:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Message-ID: <20180628090301.GC7646@bombadil.infradead.org>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
 <87r2krfpi2.fsf@yhuang-dev.intel.com>
 <20180627223118.dd2f52d87f53e7e002ed0153@linux-foundation.org>
 <87muvffp7w.fsf@yhuang-dev.intel.com>
 <20180627231839.e5ac2f38e0397979d3db7765@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180627231839.e5ac2f38e0397979d3db7765@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Wed, Jun 27, 2018 at 11:18:39PM -0700, Andrew Morton wrote:
> On Thu, 28 Jun 2018 13:35:15 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> > No problem.  I will rebase the patchset on your latest -mm tree, or the
> > next version to be released?
> 
> We need to figure that out with Matthew.
> 
> Probably the xarray conversions are simpler and more mature so yes,
> probably they should be staged first.

I'll take a look.  Honestly, my biggest problem with this patch set is
overuse of tagging:

59832     Jun 22 Huang, Ying     ( 131) [PATCH -mm -v4 00/21] mm, THP, swap: Swa
59833 N   Jun 22 Huang, Ying     ( 126) a??a??>[PATCH -mm -v4 01/21] mm, THP, swap:
59834 N   Jun 22 Huang, Ying     (  44) a??a??>[PATCH -mm -v4 02/21] mm, THP, swap:
59835 N   Jun 22 Huang, Ying     ( 583) a??a??>[PATCH -mm -v4 03/21] mm, THP, swap:
59836 N   Jun 22 Huang, Ying     ( 104) a??a??>[PATCH -mm -v4 04/21] mm, THP, swap:
59837 N   Jun 22 Huang, Ying     ( 394) a??a??>[PATCH -mm -v4 05/21] mm, THP, swap:
59838 N   Jun 22 Huang, Ying     ( 198) a??a??>[PATCH -mm -v4 06/21] mm, THP, swap:
59839 N   Jun 22 Huang, Ying     ( 161) a??a??>[PATCH -mm -v4 07/21] mm, THP, swap:
59840 N   Jun 22 Huang, Ying     ( 351) a??a??>[PATCH -mm -v4 08/21] mm, THP, swap:
59841 N   Jun 22 Huang, Ying     ( 293) a??a??>[PATCH -mm -v4 09/21] mm, THP, swap:
59842 N   Jun 22 Huang, Ying     ( 138) a??a??>[PATCH -mm -v4 10/21] mm, THP, swap:
59843 N   Jun 22 Huang, Ying     ( 264) a??a??>[PATCH -mm -v4 11/21] mm, THP, swap:
59844 N   Jun 22 Huang, Ying     ( 251) a??a??>[PATCH -mm -v4 12/21] mm, THP, swap:
59845 N   Jun 22 Huang, Ying     ( 121) a??a??>[PATCH -mm -v4 13/21] mm, THP, swap:
59846 N   Jun 22 Huang, Ying     ( 517) a??a??>[PATCH -mm -v4 14/21] mm, cgroup, THP
59847 N   Jun 22 Huang, Ying     ( 128) a??a??>[PATCH -mm -v4 15/21] mm, THP, swap:
59848 N   Jun 22 Huang, Ying     (  85) a??a??>[PATCH -mm -v4 16/21] mm, THP, swap:
59849 N   Jun 22 Huang, Ying     (  70) a??a??>[PATCH -mm -v4 17/21] mm, THP, swap:

There's literally zero useful information displayed in the patch subjects.
