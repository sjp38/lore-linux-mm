Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E95E96B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:20:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b77so4036648pfl.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:20:56 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j1si4566935pgn.374.2017.11.23.08.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 08:20:55 -0800 (PST)
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c55957c0-cf1a-eb8d-c37a-c2b69ada2312@linux.intel.com>
Date: Thu, 23 Nov 2017 08:20:51 -0800
MIME-Version: 1.0
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com

I've updated these a bit since yesterday with some minor fixes:
 * Fixed KASLR compile bug
 * Fixed ds.c compile problem
 * Changed ulong to pteval_t to fix 32-bit compile problem
 * Stop mapping cpu_current_top_of_stack (never used until after CR3 switch)

Rather than re-spamming everyone, the resulting branch is here:

https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/log/?h=kaiser-414-tipwip-20171123

If anyone wants to be re-spammed, just say the word.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
