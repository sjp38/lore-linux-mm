Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A81F16B0034
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 15:47:42 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1UqTme-0008Hc-Bj
	for linux-mm@kvack.org; Sat, 22 Jun 2013 21:47:40 +0200
Received: from c-50-132-41-203.hsd1.wa.comcast.net ([50.132.41.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 22 Jun 2013 21:47:40 +0200
Received: from eternaleye by c-50-132-41-203.hsd1.wa.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 22 Jun 2013 21:47:40 +0200
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: RFC: named anonymous vmas
Date: Sat, 22 Jun 2013 12:47:29 -0700
Message-ID: <kq4v0b$p8p$3@ger.gmane.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com> <20130622103158.GA16304@infradead.org> <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Colin Cross wrote:

> On Sat, Jun 22, 2013 at 3:31 AM, Christoph Hellwig <hch@infradead.org>
> wrote:
>> On Fri, Jun 21, 2013 at 04:42:41PM -0700, Colin Cross wrote:
>>> ranges, which John Stultz has been implementing.  The second is
>>> anonymous shareable memory without having a world-writable tmpfs that
>>> untrusted apps could fill with files.
>>
>> I still haven't seen any explanation of what ashmem buys over a shared
>> mmap of /dev/zero in that respect, btw.
> 
> I believe the difference is that ashmem ties the memory to an fd, so
> it can be passed to another process and mmaped to get to the same
> memory, but /dev/zero does not.  Passing a /dev/zero fd and mmaping it
> would result in a brand new region of zeroed memory.  Opening a tmpfs
> file would allow sharing memory by passing the fd, but we don't want a
> world-writable tmpfs.

Couldn't this be done by having a root-only tmpfs, and having a userspace 
component that creates per-app directories with restrictive permissions on 
startup/app install? Then each app creates files in its own directory, and 
can pass the fds around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
