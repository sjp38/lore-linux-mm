Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B90CB6B0010
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:03:51 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id h7-v6so150926otj.22
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:03:51 -0700 (PDT)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id s80si171369oie.24.2018.03.13.10.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 10:03:50 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/2] x86/mm: vmalloc_fault fix for CONFIG_HUGETLBFS off
Date: Tue, 13 Mar 2018 11:03:45 -0600
Message-Id: <20180313170347.3829-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: bp@alien8.de, luto@kernel.org, gratian.crisan@ni.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Gratian Crisan reported that vmalloc_fault() crashes when
CONFIG_HUGETLBFS is not set since the function inadvertently
uses pXn_huge(), which always return 0 in this case. [1]
ioremap() does not depend on CONFIG_HUGETLBFS.

Patch 01 fixes the issue in vmalloc_fault().
Patch 02 is a clean-up for vmalloc_fault().

[1] https://lkml.org/lkml/2018/3/8/1281

---
Toshi Kani (2):
 1/2 x86/mm: fix vmalloc_fault to use pXd_large
 2/2 x86/mm: remove pointless checks in vmalloc_fault

---
 arch/x86/mm/fault.c | 62 +++++++++++++++++------------------------------------
 1 file changed, 20 insertions(+), 42 deletions(-)
