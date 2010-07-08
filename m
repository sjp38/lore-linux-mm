Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 232F26006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:22:43 -0400 (EDT)
Subject: Re: [PATCH] Add trace event for munmap
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 16:22:35 +0200
Message-ID: <1278598955.1900.152.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 15:05 +0100, Eric B Munson wrote:
> This patch adds a trace event for munmap which will record the starting
> address of the unmapped area and the length of the umapped area.  This
> event will be used for modeling memory usage.

Does it make sense to couple this with a mmap()/mremap()/brk()
tracepoint?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
