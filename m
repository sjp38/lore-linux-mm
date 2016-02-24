Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 902336B0256
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:35:28 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x65so21408238pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:28 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id fm6si7957273pab.122.2016.02.24.15.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:35:27 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id q63so21394201pfb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:27 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [RFC][PATCH v3 0/2] mm/page_poison.c: Allow for zero poisoning
Date: Wed, 24 Feb 2016 15:35:21 -0800
Message-Id: <1456356923-5164-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mathias Krause <minipli@googlemail.com>, Dave Hansen <dave.hansen@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is my attempt to rebase this series:

[PATCHv2, 2/2] mm/page_poisoning.c: Allow for zero poisoning
[PATCHv2, 1/2] mm/page_poison.c: Enable PAGE_POISONING as a separate option

to the poisoning series in linux-next. It replaces the following mmotm:

mm-page_poisoningc-allow-for-zero-poisoning.patch
mm-page_poisoningc-allow-for-zero-poisoning-checkpatch-fixes.patch
mm-page_poisonc-enable-page_poisoning-as-a-separate-option.patch
mm-page_poisonc-enable-page_poisoning-as-a-separate-option-fix.patch

These patches work for me (linux-next does not) when using
CONFIG_PAGE_POISONING_ZERO=y

I've marked this RFC because I did the rebase -- bugs should be blamed
on me. :)

-Kees

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
