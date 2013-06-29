Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 95E1E6B0032
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 16:12:13 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id c10so6064828ieb.24
        for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:12:12 -0700 (PDT)
Date: Sat, 29 Jun 2013 13:12:12 -0700 (PDT)
Message-Id: <1372536729.850447@landley.net>
From: Rob Landley <rob@landley.net>
Subject: [PATCH 0/5] initmpfs: use tmpfs instead of ramfs for rootfs
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
