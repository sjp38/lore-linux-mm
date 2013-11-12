Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14C476B0031
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 17:27:41 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so7630274pbc.10
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 14:27:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.125])
        by mx.google.com with SMTP id gg8si483367pac.263.2013.11.12.14.27.38
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 14:27:39 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv2 0/4] Intermix Lowmem and Vmalloc
Date: Tue, 12 Nov 2013 14:27:28 -0800
Message-Id: <1384295252-31778-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Kyungmin Park <kmpark@infradead.org>, Russell King <linux@arm.linux.org.uk>

Hi,

This is v2 of a patch series to allow lowmem and vmalloc to be
intermixed (http://lists.infradead.org/pipermail/linux-arm-kernel/2013-November/210578.html
provides the full decriptions which I've omitted here for brevity)

Nots I forgot to mention before:
- as a side effect of how CMA is setup, the remapped lowmem regions are
explicitly printed out in /proc/vmallocinfo which has turned out to be useful
for debugging. I couldn't find a good way to support those and the lowmem
regions in vmalloc short of adding partial region unmapping.
- I still have a nagging concern about regions that straddle the lowmem/highmem
boundary causing problems. I haven't been able to find a concrete issue yet
though..

v2: Fixed several comments by Kyungmin Park which led me to discover
several issues with the is_vmalloc_addr implementation. is_vmalloc_addr
is probably the ugliest part of the entire series and I debated if
adding extra vmalloc flags would make it less ugly.

Again, comments or suggestions on how to better accomplish this are welcome.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
