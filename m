Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id CBBDE6B006E
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:32:53 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so1043640pde.37
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 08:32:53 -0700 (PDT)
From: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Subject: RE: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Date: Wed, 2 Oct 2013 15:32:47 +0000
Message-ID: <32E1700B9017364D9B60AED9960492BC211AF005@FMSMSX107.amr.corp.intel.com>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211AEF75@FMSMSX107.amr.corp.intel.com>
 <20131002152811.GC32181@quack.suse.cz>
In-Reply-To: <20131002152811.GC32181@quack.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

> > The risk of GUP fast is the loss of the "force" arg on GUP fast, which
> > I don't see as significant give our use case.
>   Yes. I was discussing with Roland some time ago whether the force
> argument is needed and he said it is. So I kept the arguments of
> get_user_pages() intact and just simplified the locking...

The PSM side of the code is a more traditional use of GUP (like direct I/O)=
, so I think it is a different use case than the locking for IB memory regi=
ons.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
