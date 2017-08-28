Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 078A36B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 03:59:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z91so9466069wrc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 00:59:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14si7766719wra.194.2017.08.28.00.59.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 00:59:33 -0700 (PDT)
Date: Mon, 28 Aug 2017 09:59:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2017-08-25-15-50 uploaded
Message-ID: <20170828075931.GC17097@dhcp22.suse.cz>
References: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org>
 <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Fri 25-08-17 16:50:26, Randy Dunlap wrote:
> On 08/25/17 15:50, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2017-08-25-15-50 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> 
> lots of this one (on x86_64, i386, or UML):
> 
> ../kernel/fork.c:818:2: error: implicit declaration of function 'hmm_mm_init' [-Werror=implicit-function-declaration]
> ../kernel/fork.c:897:2: error: implicit declaration of function 'hmm_mm_destroy' [-Werror=implicit-function-declaration]
> 
> from mm-hmm-heterogeneous-memory-management-hmm-for-short-v5.patch
> 
> Cc: Jerome Glisse <jglisse@redhat.com>

This one should address it
---
