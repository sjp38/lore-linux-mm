Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F08C56B0008
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 19:03:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n81-v6so21775208pfi.20
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:03:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j185-v6si12473636pfc.186.2018.10.15.16.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 16:03:10 -0700 (PDT)
Date: Mon, 15 Oct 2018 16:03:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: thp: relocate flush_cache_range() in
 migrate_misplaced_transhuge_page()
Message-Id: <20181015160307.7bd8e48c0eb31c39821a6b3f@linux-foundation.org>
In-Reply-To: <20181015155249.9df91c1f4bd1d593c2879b07@linux-foundation.org>
References: <20181013002430.698-4-aarcange@redhat.com>
	<20181015202311.7209-1-aarcange@redhat.com>
	<20181015155249.9df91c1f4bd1d593c2879b07@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, 15 Oct 2018 15:52:49 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Oct 2018 16:23:11 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > There should be no cache left by the time we overwrite the old
> > transhuge pmd with the new one. It's already too late to flush through
> > the virtual address because we already copied the page data to the new
> > physical address.
> > 
> > So flush the cache before the data copy.
> > 
> > Also delete the "end" variable to shutoff a "unused variable" warning
> > on x86 where flush_cache_range() is a noop.
> 
> migrate_misplaced_transhuge_page() has changed a bit.

Is OK, I figured it out :)
