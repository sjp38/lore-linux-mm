Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9760F6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:16:03 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so123961igc.14
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:16:03 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id ac8si5140913icc.0.2014.04.10.16.16.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 16:16:02 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so4698168iec.1
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:16:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrXFJfoD9xrYpu6UjsHF74kYm3_o-xLNKjqh-OF2x-nyFQ@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<20140320153250.GC20618@thunk.org>
	<CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
	<20140320163806.GA10440@thunk.org>
	<5346ED93.9040500@amacapital.net>
	<20140410203246.GB31614@thunk.org>
	<CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
	<CANq1E4RofJ7CUWWBPW1Qb4pX3rxYHCh1CPtbtX241KtJO+=Qhw@mail.gmail.com>
	<CALCETrXVzLcVVSuPMFUgoRvpQgcQNy2_rW6=11CJAME0W2GyYQ@mail.gmail.com>
	<CANq1E4Qa8N0G8whyW5OWQS4x9=CVOF0PpcLhDi4j3wGTHX0==w@mail.gmail.com>
	<CALCETrXFJfoD9xrYpu6UjsHF74kYm3_o-xLNKjqh-OF2x-nyFQ@mail.gmail.com>
Date: Fri, 11 Apr 2014 01:16:00 +0200
Message-ID: <CANq1E4SsCFTpiKBPbOUD0M+Nfs2hsnLW44RfsgbQvbFCfeZuvA@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

Hi

On Fri, Apr 11, 2014 at 1:05 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> /proc/pid/fd is a really weird corner case in which the mode of an
> inode that doesn't have a name matters.  I suspect that almost no one
> will ever want to open one of these things out of /proc/self/fd, and
> those who do should be made to think about it.

I'm arguing in the context of memfd, and there's no security leak if
people get access to the underlying inode (at least I'm not aware of
any). As I said, context information is attached to the inode, not
file context, so I'm fine if people want to open multiple file
contexts via /proc. If someone wants to forbid open(), I want to hear
_why_. I assume the memfd object has uid==uid-of-creator and
mode==(777 & ~umask) (which usually results in X00, so no access for
non-owners). I cannot see how /proc is a security issue here.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
