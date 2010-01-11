Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB5136B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 07:11:59 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <8bd0f97a1001081655s4ee3d4a7q3ef6a10d211ce6d1@mail.gmail.com>
References: <8bd0f97a1001081655s4ee3d4a7q3ef6a10d211ce6d1@mail.gmail.com> <20100108220516.23489.11319.stgit@warthog.procyon.org.uk> <20100108220533.23489.99121.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH 4/6] NOMMU: Don't need get_unmapped_area() for NOMMU
Date: Mon, 11 Jan 2010 12:11:51 +0000
Message-ID: <20843.1263211911@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mike Frysinger <vapier.adi@gmail.com> wrote:

> static inline instead of extern when !MMU ?

Yep.  The fix accidentally wound up in the next patch.  I'll move it.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
