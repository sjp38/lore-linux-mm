Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3E4E6B754B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:34:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a8-v6so4408929pla.10
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:34:22 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f10-v6si3059642pfn.85.2018.09.05.14.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 14:34:22 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <185e6fb5-f247-bba2-e082-c3097e78fc04@intel.com>
Date: Wed, 5 Sep 2018 14:34:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180905211328.3286.71674.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/05/2018 02:13 PM, Alexander Duyck wrote:
> Instead of keeping the value in CONFIG_DEBUG_VM I am adding a new CONFIG
> value called CONFIG_DEBUG_VM_PAGE_INIT_POISON that will control the page
> poisoning independent of the CONFIG_DEBUG_VM option.

I guess this is a reasonable compromise.

If folks see odd 'struct page' corruption, they'll have to know to go
turn this on and reboot, though.
