Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 387586B0770
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 22:54:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l15-v6so2968684pff.5
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 19:54:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e193-v6sor2092705pfc.67.2018.11.09.19.54.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 19:54:46 -0800 (PST)
Date: Fri, 9 Nov 2018 19:54:43 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-ID: <20181110035443.GA26579@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <20181109123634.6fe7467bb9237851250c9c56@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109123634.6fe7467bb9237851250c9c56@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, dancol@google.com, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei Yang <Lei.Yang@windriver.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, minchan@kernel.org, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu

On Fri, Nov 09, 2018 at 12:36:34PM -0800, Andrew Morton wrote:
> On Wed,  7 Nov 2018 20:15:36 -0800 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > Android uses ashmem for sharing memory regions. We are looking forward
> > to migrating all usecases of ashmem to memfd so that we can possibly
> > remove the ashmem driver in the future from staging while also
> > benefiting from using memfd and contributing to it. Note staging drivers
> > are also not ABI and generally can be removed at anytime.
> > 
> > One of the main usecases Android has is the ability to create a region
> > and mmap it as writeable, then add protection against making any
> > "future" writes while keeping the existing already mmap'ed
> > writeable-region active.  This allows us to implement a usecase where
> > receivers of the shared memory buffer can get a read-only view, while
> > the sender continues to write to the buffer.
> > See CursorWindow documentation in Android for more details:
> > https://developer.android.com/reference/android/database/CursorWindow
> 
> It appears that the memfd_create and fcntl manpages will require
> updating.  Please attend to this at the appropriate time?

Yes, I am planning to send those out shortly. I finished working on them.

Also just to let you know, I posted a fix for the security issue Jann Horn
reported and requested him to test it:
https://lore.kernel.org/lkml/20181109234636.GA136491@google.com/T/#m8d9d185e6480d095f0ab8f84bcb103892181f77d

This fix along with the 2 other patches I posted in v3 are all that's needed. thanks!

- Joel
