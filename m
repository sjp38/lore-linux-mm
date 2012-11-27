Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 05AB26B0062
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 11:03:07 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: O_DIRECT on tmpfs (again)
Date: Tue, 27 Nov 2012 11:03:03 -0500
Message-ID: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hi Hugh and others,

In 2007, there were some discussions on whether to allow opens to
specify O_DIRECT for files backed by tmpfs.[1][2] On the surface, it
sounds like a completely crazy thing to do.  However, distributions like
Fedora are now defaulting to using a tmpfs /tmp.  I'm not aware of any
applications that open temp files using O_DIRECT, but I wanted to get
some new discussion going on whether this is a reasonable thing to
expect to work.

Thoughts?

Cheers,
Jeff

[1] https://lkml.org/lkml/2007/1/4/55
[2] http://thread.gmane.org/gmane.linux.kernel/482031

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
