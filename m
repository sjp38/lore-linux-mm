Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCD5B6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 16:21:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b5-v6so5400625ple.20
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:21:35 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 63-v6si55101pld.374.2018.07.19.13.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 13:21:34 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] swap: THP optimizing refactoring
References: <20180719084842.11385-1-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b4f11dbd-ed90-5314-6355-394ee5d990fa@linux.intel.com>
Date: Thu, 19 Jul 2018 13:21:33 -0700
MIME-Version: 1.0
In-Reply-To: <20180719084842.11385-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

These all look sane to me and the size increases are modest and well
worth the cleanup.

Feel free to add my ack on these.
