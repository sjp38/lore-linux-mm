Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 424FE6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:49:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z5-v6so5162511pfz.6
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:49:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f17-v6si15193372pgv.383.2018.06.07.15.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:49:29 -0700 (PDT)
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
Date: Thu, 7 Jun 2018 15:48:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180521101555.25610-4-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 05/21/2018 03:15 AM, Baoquan He wrote:
> It's used to pass the size of map data unit into alloc_usemap_and_memmap,
> and is preparation for next patch.

This is the "what", but not the "why".  Could you add another sentence
or two to explain why we need this?
