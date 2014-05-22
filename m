Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id D7CF46B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 04:35:11 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so2406929lab.16
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:35:10 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id jo6si22812386lab.53.2014.05.22.01.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:35:10 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so2337070lbv.21
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:35:09 -0700 (PDT)
Date: Thu, 22 May 2014 12:35:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: /prom/pid/clear_refs: avoid split_huge_page()
Message-ID: <20140522083506.GC8946@moon>
References: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140521123446.ae45fa676cae27fffbd96cfd@linux-foundation.org>
 <20140522011110.B0090E009B@blue.fi.intel.com>
 <20140522053247.GA8946@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140522053247.GA8946@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, May 22, 2014 at 09:32:47AM +0400, Cyrill Gorcunov wrote:
> On Thu, May 22, 2014 at 04:11:10AM +0300, Kirill A. Shutemov wrote:
> > Andrew Morton wrote:
> > > On Wed, 21 May 2014 22:04:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > > Currently we split all THP pages on any clear_refs request. It's not
> > > > necessary. We can handle this on PMD level.
> > > > 
> > > > One side effect is that soft dirty will potentially see more dirty
> > > > memory, since we will mark whole THP page dirty at once.
> > > 
> > > This clashes pretty badly with
> > > http://ozlabs.org/~akpm/mmots/broken-out/clear_refs-redefine-callback-functions-for-page-table-walker.patch
> > 
> > Hm.. For some reason CRIU memory-snapshotting test cases fail on current
> > linux-next. I didn't debug why. Mainline works. Folks?
> 
> Thanks for noticing, Kirill! I don't test linux-test regulary will try and
> report the results.

OK, I managed to run criu on linux-next. Due to changes in vdso it no longer
able to run. I'll handle it in criu and ping you then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
