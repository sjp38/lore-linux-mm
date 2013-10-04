Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B80446B0031
	for <linux-mm@kvack.org>; Fri,  4 Oct 2013 09:52:53 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so4034845pdj.2
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 06:52:53 -0700 (PDT)
From: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Subject: RE: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Date: Fri, 4 Oct 2013 13:52:49 +0000
Message-ID: <32E1700B9017364D9B60AED9960492BC211B0176@FMSMSX107.amr.corp.intel.com>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-24-git-send-email-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

> Convert qib_get_user_pages() to use get_user_pages_unlocked().  This
> shortens the section where we hold mmap_sem for writing and also removes
> the knowledge about get_user_pages() locking from ipath driver. We also f=
ix
> a bug in testing pinned number of pages when changing the code.
>=20

This patch and the sibling ipath patch will nominally take the mmap_sem twi=
ce where the old routine only took it once.   This is a performance issue.

Is the intent here to deprecate get_user_pages()?

I agree, the old code's lock limit test is broke and needs to be fixed.   I=
 like the elimination of the silly wrapper routine!

Could the lock limit test be pushed into another version of the wrapper so =
that there is only one set of mmap_sem transactions?

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
