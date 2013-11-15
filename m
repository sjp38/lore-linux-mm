Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 87BC46B0036
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:09:25 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so4173850pab.20
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:09:25 -0800 (PST)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id n8si3103581pax.218.2013.11.15.14.09.23
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 14:09:24 -0800 (PST)
Received: by mail-vb0-f41.google.com with SMTP id w8so3238858vbj.0
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:09:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbL-WpcC6_wfZeFW6Buqq0p1PStH5ScF-USHae40H3MXfg@mail.gmail.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+8MBbL-WpcC6_wfZeFW6Buqq0p1PStH5ScF-USHae40H3MXfg@mail.gmail.com>
Date: Fri, 15 Nov 2013 14:09:21 -0800
Message-ID: <CA+8MBbJR+AbGY41=TMOfJUd2u927ADa8O_-12sFUcNYnN34oMw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Properly separate the bloated ptl from the
 regular case
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Nov 15, 2013 at 2:01 PM, Tony Luck <tony.luck@gmail.com> wrote:
> My "grep" skills are failing to find the Makefile that decides it wants to build
> kernel/bounds.s so early :-(

... and then seconds later I found it in the top-level "Kbuild" file.

But it looks ugly ... comment says we might need this before asm-offsets.h
(which is the reverse of the ia64 case ... we need asm-offsets.h before we
can make bounds.s).

Help!

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
