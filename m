Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 09A9D6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 03:32:55 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so9011407qga.0
        for <linux-mm@kvack.org>; Tue, 13 May 2014 00:32:54 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id e10si7096700qco.51.2014.05.13.00.32.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 00:32:54 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id w7so8981423qcr.6
        for <linux-mm@kvack.org>; Tue, 13 May 2014 00:32:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5370E4B4.1060802@oracle.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20140508145729.3d82d2c989cfc483c94eb324@linux-foundation.org> <5370E4B4.1060802@oracle.com>
From: Armin Rigo <arigo@tunes.org>
Date: Tue, 13 May 2014 09:32:13 +0200
Message-ID: <CAMSv6X0yg4haVtUifFrdkCCZjJV-TLXJ-KsiCPiBue0Y0qNTcQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Hi Sasha,

On 12 May 2014 17:11, Sasha Levin <sasha.levin@oracle.com> wrote:
> Since we can't find any actual users,

The PyPy project doesn't count as an "actual user"?  It's not just an
idea in the air.  It's beta code that is already released (and open
source):

http://morepypy.blogspot.ch/2014/04/stm-results-and-second-call-for.html

The core library is available from there (see the test suite in c7/test/):

https://bitbucket.org/pypy/stmgc

I already reacted to the discussion here by making remap_file_pages()
optional (#undef USE_REMAP_FILE_PAGES) but didn't measure the
performance impact of this, if any (I expect it to be reasonable).
Still, if you're looking for a real piece of code using
remap_file_pages(), it's one.


A bient=C3=B4t,

Armin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
