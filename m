Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 909016B02AD
	for <linux-mm@kvack.org>; Wed, 30 May 2018 07:16:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so10671769pfi.8
        for <linux-mm@kvack.org>; Wed, 30 May 2018 04:16:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u28-v6si11902345pgn.227.2018.05.30.04.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 04:16:49 -0700 (PDT)
Date: Wed, 30 May 2018 04:16:02 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180530111602.GB17450@bombadil.infradead.org>
References: <20180529143126.GA19698@jordon-HP-15-Notebook-PC>
 <20180529145055.GA15148@bombadil.infradead.org>
 <CAFqt6zaxt=wXjvKV0qA+OwU1iUyoBdW2cJSLFqXupVWRpKdqEA@mail.gmail.com>
 <20180529173445.GD15148@bombadil.infradead.org>
 <CAFqt6zZCX7Ai2w9dV3OvUn=V4Z02H=+FBirjHT3QSU1Fuz+uLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZCX7Ai2w9dV3OvUn=V4Z02H=+FBirjHT3QSU1Fuz+uLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, zi.yan@cs.rutgers.edu, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, Kate Stewart <kstewart@linuxfoundation.org>, David Rientjes <rientjes@google.com>, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, yang.s@alibaba-inc.com, Minchan Kim <minchan@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Wed, May 30, 2018 at 09:10:47AM +0530, Souptick Joarder wrote:
> On Tue, May 29, 2018 at 11:04 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > I see:
> >
> > mm/gup.c:817:15: warning: invalid assignment: |=
> > mm/gup.c:817:15:    left side has type int
> > mm/gup.c:817:15:    right side has type restricted vm_fault_t
> >
> > are you building with 'c=2' or 'C=2'?
> 
> Building with C=2.
> Do I need to enable any separate FLAG ?

Nope.  Here's what I have:

willy@bobo:~/kernel/souptick$ make C=2 mm/gup.o
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHECK   arch/x86/purgatory/purgatory.c
  CHECK   arch/x86/purgatory/sha256.c
  CHECK   arch/x86/purgatory/string.c
arch/x86/purgatory/../boot/string.c:134:6: warning: symbol 'simple_strtol' was not declared. Should it be static?
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  DESCEND  objtool
  CHECK   scripts/mod/empty.c
  CHK     scripts/mod/devicetable-offsets.h
  CHECK   mm/gup.c
mm/gup.c:817:15: warning: invalid assignment: |=
mm/gup.c:817:15:    left side has type int
mm/gup.c:817:15:    right side has type restricted vm_fault_t
  CC      mm/gup.o
