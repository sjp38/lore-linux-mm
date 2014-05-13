Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 63EEB6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 08:58:17 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id rp18so259895iec.18
        for <linux-mm@kvack.org>; Tue, 13 May 2014 05:58:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id hi5si11650249icc.185.2014.05.13.05.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 05:58:16 -0700 (PDT)
Message-ID: <537216C5.7050204@oracle.com>
Date: Tue, 13 May 2014 08:57:41 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com> <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com> <20140508145729.3d82d2c989cfc483c94eb324@linux-foundation.org> <5370E4B4.1060802@oracle.com> <CAMSv6X0yg4haVtUifFrdkCCZjJV-TLXJ-KsiCPiBue0Y0qNTcQ@mail.gmail.com>
In-Reply-To: <CAMSv6X0yg4haVtUifFrdkCCZjJV-TLXJ-KsiCPiBue0Y0qNTcQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Armin Rigo <arigo@tunes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

On 05/13/2014 03:32 AM, Armin Rigo wrote:
> Hi Sasha,
> 
> On 12 May 2014 17:11, Sasha Levin <sasha.levin@oracle.com> wrote:
>> Since we can't find any actual users,
> 
> The PyPy project doesn't count as an "actual user"?  It's not just an
> idea in the air.  It's beta code that is already released (and open
> source):
> 
> http://morepypy.blogspot.ch/2014/04/stm-results-and-second-call-for.html
> 
> The core library is available from there (see the test suite in c7/test/):
> 
> https://bitbucket.org/pypy/stmgc
> 
> I already reacted to the discussion here by making remap_file_pages()
> optional (#undef USE_REMAP_FILE_PAGES) but didn't measure the
> performance impact of this, if any (I expect it to be reasonable).
> Still, if you're looking for a real piece of code using
> remap_file_pages(), it's one.

Oh, I don't have anything against PyPy, I just wasn't aware it used
remap_file_pages() (I think I've missed the discussion in the parallel
thread).

Indeed it is a user, have you tried it with a kernel that is running
Kirill's patch set to replace remap_file_pages()?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
