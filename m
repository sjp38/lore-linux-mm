Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F9B6B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 11:48:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so6501318wrg.11
        for <linux-mm@kvack.org>; Sat, 26 May 2018 08:48:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9-v6sor13784521wrn.65.2018.05.26.08.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 08:48:22 -0700 (PDT)
Date: Sat, 26 May 2018 18:48:19 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Message-ID: <20180526154819.GA14016@avx2>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

On Sat, May 26, 2018 at 04:50:46PM +0200, Salvatore Mesoraca wrote:
> Prevent a task from opening, in "write" mode, any /proc/*/mem
> file that operates on the task's mm.
> /proc/*/mem is mainly a debugging means and, as such, it shouldn't
> be used by the inspected process itself.
> Current implementation always allow a task to access its own
> /proc/*/mem file.
> A process can use it to overwrite read-only memory, making
> pointless the use of security_file_mprotect() or other ways to
> enforce RO memory.

You can do it in security_ptrace_access_check() or security_file_open()
