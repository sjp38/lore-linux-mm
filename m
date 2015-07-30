Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id ACEEA6B0257
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:32:58 -0400 (EDT)
Received: by lahh5 with SMTP id h5so26273639lah.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:32:58 -0700 (PDT)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id es2si3698258wib.12.2015.07.30.07.32.56
        for <linux-mm@kvack.org>;
        Thu, 30 Jul 2015 07:32:56 -0700 (PDT)
Received: from localhost.localdomain ([127.0.0.1]:45849 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27011420AbbG3OczuEDWM (ORCPT <rfc822;linux-mm@kvack.org>);
        Thu, 30 Jul 2015 16:32:55 +0200
Date: Thu, 30 Jul 2015 16:32:52 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH V6 6/6] mips: Add entry for new mlock2 syscall
Message-ID: <20150730143252.GF25552@linux-mips.org>
References: <1438184575-10537-1-git-send-email-emunson@akamai.com>
 <1438184575-10537-7-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438184575-10537-7-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 29, 2015 at 11:42:55AM -0400, Eric B Munson wrote:

> A previous commit introduced the new mlock2 syscall, add entries for the
> MIPS architecture.

Looking good, so

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Recently somebody else was floating around a patch that was adding
three syscalls.  Not sure if in the end the adding the syscall part to
non-x86 was dropped.  Just mentioning in case there are any conflicts;
in particulary nobody should rely on syscall numbers unless they're
for something in Linus' tree!

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
