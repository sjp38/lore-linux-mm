Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CEF786B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 16:04:51 -0400 (EDT)
Subject: Re: [PATCH] Add munmap events to perf
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1277748484-23882-1-git-send-email-ebmunson@us.ibm.com>
References: <1277748484-23882-1-git-send-email-ebmunson@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Jun 2010 22:04:46 +0200
Message-ID: <1277755486.3561.140.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: mingo@elte.hu, paulus@samba.org, acme@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-28 at 19:08 +0100, Eric B Munson wrote:
> This patch adds a new software event for munmaps.  It will allows
> users to profile changes to address space.  munmaps will be tracked
> with mmaps.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
