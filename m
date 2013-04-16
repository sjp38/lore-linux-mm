Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 7FA7A6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 18:14:10 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id va7so913784obc.34
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 15:14:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <30949.1366150057@warthog.procyon.org.uk>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
 <20130416182601.27773.46395.stgit@warthog.procyon.org.uk> <CAHGf_=r+qoL8_J+z8Y1uPt_NK1Ef4cLuapAvVd-7qF8+_oSjJw@mail.gmail.com>
 <30949.1366150057@warthog.procyon.org.uk>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 16 Apr 2013 15:13:49 -0700
Message-ID: <CAHGf_=p7iKG0hqzanTb6u3-RUFsOZ3wJVYfLYhqH9nF6RkxGow@mail.gmail.com>
Subject: Re: [PATCH 03/28] proc: Split kcore bits from linux/procfs.h into
 linux/kcore.h [RFC]
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips <linux-mips@linux-mips.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, x86@kernel.org, sparclinux@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, Apr 16, 2013 at 3:07 PM, David Howells <dhowells@redhat.com> wrote:
>
> KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
>
>> I have no seen any issue in this change. but why? Is there any
>> motivation rather than cleanup?
>
> Stopping stuff mucking about with the internals of procfs incorrectly
> (sometimes because the internals of procfs have changed, but the drivers
> haven't).

OK, thank you for explanation.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
