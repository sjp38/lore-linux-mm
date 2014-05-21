Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B84B96B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 18:42:53 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1828574pab.21
        for <linux-mm@kvack.org>; Wed, 21 May 2014 15:42:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ce7si30963647pad.113.2014.05.21.15.42.52
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 15:42:52 -0700 (PDT)
Date: Wed, 21 May 2014 15:42:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Message-Id: <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
In-Reply-To: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

On Tue, 20 May 2014 22:26:30 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This patchset adds a new procfs interface to extrace information about
> pagecache status. In-kernel tool tools/vm/page-types.c has already some
> code for pagecache scanning without kernel's help, but it's not free
> from measurement-disturbance, so here I'm suggesting another approach.

I'm not seeing much explanation of why you think the kernel needs this.
The overall justification for a change is terribly important so please
do spend some time on it.

As I don't *really* know what the patch is for, I can't comment a lot
further, but...


A much nicer interface would be for us to (finally!) implement
fincore(), perhaps with an enhanced per-present-page payload which
presents the info which you need (although we don't actually know what
that info is!).

This would require open() - it appears to be a requirement that the
caller not open the file, but no reason was given for this.

Requiring open() would address some of the obvious security concerns,
but it will still be possible for processes to poke around and get some
understanding of the behaviour of other processes.  Careful attention
should be paid to this aspect of any such patchset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
