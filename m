Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 00A416B0089
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 17:47:50 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so17683igb.4
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 14:47:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o11si4204897icd.103.2014.07.24.14.47.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 14:47:50 -0700 (PDT)
Date: Thu, 24 Jul 2014 14:47:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/6] File Sealing & memfd_create()
Message-Id: <20140724144747.3041b208832bbdf9fbce5d96@linux-foundation.org>
In-Reply-To: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
References: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>

On Sun, 20 Jul 2014 19:34:34 +0200 David Herrmann <dh.herrmann@gmail.com> wrote:

> This is v4 of the File-Sealing and memfd_create() patches. You can find v1 with
> a longer introduction at gmane [1], there's also v2 [2] and v3 [3] available.
> See also the article about sealing on LWN [4], and a high-level introduction on
> the new API in my blog [5]. Last but not least, man-page proposals are
> available in my private repository [6].
>
> ...
>
>
> [1]    memfd v1: http://thread.gmane.org/gmane.comp.video.dri.devel/102241
> [2]    memfd v2: http://thread.gmane.org/gmane.linux.kernel.mm/115713
> [3]    memfd v3: http://thread.gmane.org/gmane.linux.kernel.mm/118721
> [4] LWN article: https://lwn.net/Articles/593918/
> [5]   API Intro: http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/
> [6]   Man-pages: http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd
> [7]    Dev-repo: http://cgit.freedesktop.org/~dvdhrm/linux/log/?h=memfd

This is unconventional and a little irritating.  I'm OK with running
around chasing down web pages but we generally don't do that in
changelogs.  I'm not sure why really, maybe partly because things
bitrot, partly because that's where people expect to find things,
partly because people like work down caves and on airplanes ;)

Another downside is that if a reviewer wants to comment on some piece
of text, it isn't available for the usual reply-to-all quoting.


So...  Could you please put together a plain old text/plain changelog
which actually describes this patchset and send it along?  Everything
which people need/want to know, all in one place?  That text should be
maintained alongside the patches themselves, should there be future
versions.

Now excuse me, I have a bunch of web pages to go and read ;)

<reads "[1]    memfd v1">

OK, I immediately have questions and I see significant review feedback,
so either that document is out of date or that review feedback was
ignored.

Help.  Where do I (and all future readers of these patches) go to get
an up to date and complete description of this patchset??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
