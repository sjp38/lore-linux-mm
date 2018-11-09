Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 198206B071B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 15:36:39 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g21-v6so2328603pfg.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 12:36:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d3-v6si9886642pln.204.2018.11.09.12.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 12:36:37 -0800 (PST)
Date: Fri, 9 Nov 2018 12:36:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-Id: <20181109123634.6fe7467bb9237851250c9c56@linux-foundation.org>
In-Reply-To: <20181108041537.39694-1-joel@joelfernandes.org>
References: <20181108041537.39694-1-joel@joelfernandes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, dancol@google.com, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei Yang <Lei.Yang@windriver.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?ISO-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, minchan@kernel.org, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu

On Wed,  7 Nov 2018 20:15:36 -0800 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:

> Android uses ashmem for sharing memory regions. We are looking forward
> to migrating all usecases of ashmem to memfd so that we can possibly
> remove the ashmem driver in the future from staging while also
> benefiting from using memfd and contributing to it. Note staging drivers
> are also not ABI and generally can be removed at anytime.
> 
> One of the main usecases Android has is the ability to create a region
> and mmap it as writeable, then add protection against making any
> "future" writes while keeping the existing already mmap'ed
> writeable-region active.  This allows us to implement a usecase where
> receivers of the shared memory buffer can get a read-only view, while
> the sender continues to write to the buffer.
> See CursorWindow documentation in Android for more details:
> https://developer.android.com/reference/android/database/CursorWindow

It appears that the memfd_create and fcntl manpages will require
updating.  Please attend to this at the appropriate time?

Actually, it would help the review process if those updates were
available now.
