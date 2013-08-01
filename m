Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 281E16B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 04:29:54 -0400 (EDT)
Date: Thu, 1 Aug 2013 01:29:51 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: named anonymous vmas
Message-ID: <20130801082951.GA23563@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
 <20130622103158.GA16304@infradead.org>
 <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>, libc-alpha@sourceware.org

Btw, FreeBSD has an extension to shm_open to create unnamed but fd
passable segments.  From their man page:

    As a FreeBSD extension, the constant SHM_ANON may be used for the path
    argument to shm_open().  In this case, an anonymous, unnamed shared
    memory object is created.  Since the object has no name, it cannot be
    removed via a subsequent call to shm_unlink().  Instead, the shared
    memory object will be garbage collected when the last reference to the
    shared memory object is removed.  The shared memory object may be shared
    with other processes by sharing the file descriptor via fork(2) or
    sendmsg(2).  Attempting to open an anonymous shared memory object with
    O_RDONLY will fail with EINVAL. All other flags are ignored.

To me this sounds like the best way to expose this functionality to the
user.  Implementing it is another question as shm_open sits in libc,
we could either take it and shm_unlink to the kernel, or use O_TMPFILE
on tmpfs as the backend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
