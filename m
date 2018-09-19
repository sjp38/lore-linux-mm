Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAF998E0008
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:15:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so2957501pgq.5
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:15:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 3-v6si24113886plh.207.2018.09.19.14.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:15:34 -0700 (PDT)
Subject: Re: [PATCH 0/7] mm: faster get user pages
References: <20180919210250.28858-1-keith.busch@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <40b392d0-0642-2d9b-5325-664a328ff677@intel.com>
Date: Wed, 19 Sep 2018 14:15:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On 09/19/2018 02:02 PM, Keith Busch wrote:
> Pinning user pages out of nvdimm dax memory is significantly slower
> compared to system ram. Analysis points to software overhead incurred
> from a radix tree lookup. This patch series fixes that by removing the
> relatively costly dev_pagemap lookup that was repeated for each page,
> significantly increasing gup time.

Could you also remind us why DAX pages are such special snowflakes and
*require* radix tree lookups in the first place?
