Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 249FA6B0083
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 05:13:34 -0400 (EDT)
Received: from localhost.localdomain ([127.0.0.1]:34160 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6823020Ab3DQJNcmpVtF (ORCPT <rfc822;linux-mm@kvack.org>);
        Wed, 17 Apr 2013 11:13:32 +0200
Date: Wed, 17 Apr 2013 11:13:08 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 03/28] proc: Split kcore bits from linux/procfs.h into
 linux/kcore.h [RFC]
Message-ID: <20130417091308.GA9292@linux-mips.org>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
 <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, x86@kernel.org, sparclinux@vger.kernel.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org

On Tue, Apr 16, 2013 at 07:26:01PM +0100, David Howells wrote:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
