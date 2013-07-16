From: Rob Landley <rob@landley.net>
Subject: [PATCH 0/5] initmpfs v2: use tmpfs instead of ramfs for rootfs
Date: Tue, 16 Jul 2013 08:31:13 -0700 (PDT)
Message-ID: <20130715140135.0f896a584fec9f7861049b64__1735.2064409808$1373988683$gmane$org@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Uz7Df-00076R-Vx
	for glkm-linux-mm-2@m.gmane.org; Tue, 16 Jul 2013 17:31:16 +0200
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 557506B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 11:31:14 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id 16so1943334iea.17
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 08:31:13 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Jeff Layton <jlayton@redhat.com>, Jens Axboe <axboe@kernel.dk>, Jim Cromie <jim.cromie@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>, Stephen Warren <swarren@nvidia.com>

Use tmpfs for rootfs when CONFIG_TMPFS=y and there's no root=.
Specify rootfstype=ramfs to get the old initramfs behavior.

The previous initramfs code provided a fairly crappy root filesystem:
didn't let you --bind mount directories out of it, reported zero
size/usage so it didn't show up in "df" and couldn't run things like
rpm that query available space before proceeding, would fill up all
available memory and panic the system if you wrote too much to it...

Using tmpfs instead provides a much better root filesystem.

Changes from last time: use test_and_set_bit() for "once" logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
