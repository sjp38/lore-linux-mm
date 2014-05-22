Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id EAC2E6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 01:32:50 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so2246363lbd.36
        for <linux-mm@kvack.org>; Wed, 21 May 2014 22:32:50 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id kv5si22399616lac.74.2014.05.21.22.32.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 22:32:49 -0700 (PDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so701385lab.40
        for <linux-mm@kvack.org>; Wed, 21 May 2014 22:32:48 -0700 (PDT)
Date: Thu, 22 May 2014 09:32:47 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: /prom/pid/clear_refs: avoid split_huge_page()
Message-ID: <20140522053247.GA8946@moon>
References: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140521123446.ae45fa676cae27fffbd96cfd@linux-foundation.org>
 <20140522011110.B0090E009B@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140522011110.B0090E009B@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, May 22, 2014 at 04:11:10AM +0300, Kirill A. Shutemov wrote:
> Andrew Morton wrote:
> > On Wed, 21 May 2014 22:04:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > Currently we split all THP pages on any clear_refs request. It's not
> > > necessary. We can handle this on PMD level.
> > > 
> > > One side effect is that soft dirty will potentially see more dirty
> > > memory, since we will mark whole THP page dirty at once.
> > 
> > This clashes pretty badly with
> > http://ozlabs.org/~akpm/mmots/broken-out/clear_refs-redefine-callback-functions-for-page-table-walker.patch
> 
> Hm.. For some reason CRIU memory-snapshotting test cases fail on current
> linux-next. I didn't debug why. Mainline works. Folks?

Thanks for noticing, Kirill! I don't test linux-test regulary will try and
report the results.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
