Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 14F546B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 18:07:42 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAHGf_=r+qoL8_J+z8Y1uPt_NK1Ef4cLuapAvVd-7qF8+_oSjJw@mail.gmail.com>
References: <CAHGf_=r+qoL8_J+z8Y1uPt_NK1Ef4cLuapAvVd-7qF8+_oSjJw@mail.gmail.com> <20130416182550.27773.89310.stgit@warthog.procyon.org.uk> <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH 03/28] proc: Split kcore bits from linux/procfs.h into linux/kcore.h [RFC]
Date: Tue, 16 Apr 2013 23:07:37 +0100
Message-ID: <30949.1366150057@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: dhowells@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, x86@kernel.org, sparclinux@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>


KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> I have no seen any issue in this change. but why? Is there any
> motivation rather than cleanup?

Stopping stuff mucking about with the internals of procfs incorrectly
(sometimes because the internals of procfs have changed, but the drivers
haven't).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
