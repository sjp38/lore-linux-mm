Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 04CE16B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 17:37:35 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id o17so847661oag.4
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 14:37:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk> <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 16 Apr 2013 14:37:14 -0700
Message-ID: <CAHGf_=r+qoL8_J+z8Y1uPt_NK1Ef4cLuapAvVd-7qF8+_oSjJw@mail.gmail.com>
Subject: Re: [PATCH 03/28] proc: Split kcore bits from linux/procfs.h into
 linux/kcore.h [RFC]
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, x86@kernel.org, sparclinux@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, Apr 16, 2013 at 11:26 AM, David Howells <dhowells@redhat.com> wrote:
> Split kcore bits from linux/procfs.h into linux/kcore.h.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: linux-mips@linux-mips.org
> cc: sparclinux@vger.kernel.org
> cc: x86@kernel.org
> cc: linux-mm@kvack.org

I have no seen any issue in this change. but why? Is there any
motivation rather than cleanup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
