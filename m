Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FAE66B0367
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 11:35:32 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id b41so1017377oth.4
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 08:35:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x57sor463423oth.121.2018.01.03.08.35.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 08:35:31 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: Crashes with KPTI and -rc6
Message-ID: <5b0de7f2-0753-dbfc-e6d3-a5bac3a02a3d@redhat.com>
Date: Wed, 3 Jan 2018 08:35:29 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi,

Fedora got a report via IRC of a double fault with KPTI
https://paste.fedoraproject.org/paste/SL~of04ZExXP6AN2gcJi7A

This is on -rc6 . I saw the one fix posted already which
I'll pull in but I wanted to report this as a heads up
in case there are other issues.

Full tree and configs are at
https://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git/log/?h=rawhide

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
