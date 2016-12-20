Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 900466B02FD
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:07:09 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so53397523wjo.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:09 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id 71si18907931wmp.95.2016.12.20.05.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:07:08 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id xy5so27551097wjc.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:08 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2 v2] mm, slab: consolidate KMALLOC_MAX_SIZE
Date: Tue, 20 Dec 2016 14:06:57 +0100
Message-Id: <20161220130659.16461-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <cl@linux.com>, Alexei Starovoitov <ast@kernel.org>, Andrey Konovalov <andreyknvl@google.com>, netdev@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is the second version of the patchset previously posted here [1].
Alexei has insisted on the patches reordering which I've done in this
series. I've also updated the changelog of the second patch to mention
why KMALLOC_SHIFT_MAX has been used.

Andrey has revealed a discrepancy between KMALLOC_MAX_SIZE and the
maximum supported page allocator size [2]. The underlying problem
should be fixed in the ep_write_iter code of course, but I do not feel
qualified to do that. The discrepancy which it reveals (see patch 2)
is worth fixing anyway, though.

While I was looking into the code, I've noticed that the only code which
uses KMALLOC_SHIFT_MAX outside of the slab code is bpf so I've updated
it to use KMALLOC_MAX_SIZE instead. There shouldn't be any real reason
to use KMALLOC_SHIFT_MAX which is a slab internal constant same as
KMALLOC_SHIFT_{LOW,HIGH}

[1] http://lkml.kernel.org/r/20161215164722.21586-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/CAAeHK+ztusS68DejO8AH3nn-EfiYQpD5FmBwmqKG8BWvoqPNqQ@mail.gm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
