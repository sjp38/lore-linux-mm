Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 077486B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 15:54:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l85-v6so1747570pfb.18
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 12:54:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x10-v6si48273981plv.1.2018.06.05.12.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 12:54:31 -0700 (PDT)
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
 <bfc2e579-915f-24db-0ff0-29bd9148b8c0@intel.com>
 <20180605191245.3owve7gfut22tyob@techsingularity.net>
 <ecb75c29-3d1b-3b5e-ec9d-59c4f6c1ef08@intel.com>
 <20180605195140.afc7xzgbre26m76l@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9dc03a4b-d359-8817-a950-b98e246dcd95@intel.com>
Date: Tue, 5 Jun 2018 12:54:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180605195140.afc7xzgbre26m76l@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/05/2018 12:51 PM, Mel Gorman wrote:
> Using another testcase that simply calls mremap heavily with varying number
> of threads, it was found that very broadly speaking that TLB shootdowns
> were reduced by 31% on average throughout the entire test case but your
> milage will vary.

Looks good to me.  Feel free to add my Reviewed-by.
