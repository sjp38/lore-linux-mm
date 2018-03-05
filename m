Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 731676B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:35:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 189so7711674pge.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:35:45 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d11si8789177pgn.21.2018.03.05.11.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:35:44 -0800 (PST)
Subject: Re: [PATCH v12 02/11] mm, swap: Add infrastructure for saving page
 metadata on swap
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <f5316c71e645d99ffdd52963f1e9675de3fc6386.1519227112.git.khalid.aziz@oracle.com>
 <0d77dc3c-1454-a689-a0fb-f07e8973c29e@linux.intel.com>
 <4a766f6d-ba96-7963-b367-7214eab7e307@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d807ba68-decd-e195-f607-ef6962e40c96@linux.intel.com>
Date: Mon, 5 Mar 2018 11:35:42 -0800
MIME-Version: 1.0
In-Reply-To: <4a766f6d-ba96-7963-b367-7214eab7e307@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, mgorman@techsingularity.net, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, shli@fb.com, mingo@kernel.org, jglisse@redhat.com, me@tobin.cc, anthony.yznaga@oracle.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 11:29 AM, Khalid Aziz wrote:
> ADI data is per page data and is held in the spare bits in the RAM. It
> is loaded into the cache when data is loaded from RAM and flushed out to
> spare bits in the RAM when data is flushed from cache. Sparc allows one
> tag for each ADI block size of data and ADI block size is same as
> cacheline size.

Which does not square with your earlier assertion "ADI data is per page
data".  It's per-cacheline data.  Right?

> When a page is loaded into RAM from swap space, all of
> the associated ADI data for the page must also be loaded into the RAM,
> so it looks like page level data and storing it in page level software
> data structure makes sense. I am open to other suggestions though.

Do you have a way to tell that data is not being thrown away?  Like if
the ADI metadata is different for two different cachelines within a
single page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
