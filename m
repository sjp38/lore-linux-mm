Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id ABEBF6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 13:14:17 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so7211302qac.5
        for <linux-mm@kvack.org>; Mon, 12 May 2014 10:14:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 75si6383375qgm.181.2014.05.12.10.14.16
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 10:14:17 -0700 (PDT)
Date: Mon, 12 May 2014 13:14:09 -0400
From: Dave Jones <davej@redhat.com>
Subject: Trinity 1.4 tarball release.
Message-ID: <20140512171409.GA32653@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

I finally got around to cutting a new release of trinity, hopefully
putting off the "are you running git, or tarball?" questions for a while.

Big changes since 1.3 include some more targetted fuzzing of VM related
syscalls, which judging from the fallout over the last six months, seems
to be working quite well.

Trinity should now also scale up a lot better on bigger machines with lots of cores.
It should pick a reasonable default number of child processes, but you
can override with -C as you could before, but now without any restrictions other
than available memory.  (I'd love to hear stories of people running it
on some of the more extreme systems, especially if something interesting broke)

Info, tarballs, and pointers to git are as always, at
http://codemonkey.org.uk/projects/trinity/

thanks to everyone who sent patches, chased down interesting kernel bugs
trinity found, or who gave me ideas/feedback. Your input has been much
appreciated.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
