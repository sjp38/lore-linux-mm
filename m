Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82C086B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 16:01:00 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so1833833wmg.8
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 13:01:00 -0700 (PDT)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id l31-v6si7755398eda.427.2018.06.05.13.00.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 13:00:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 0D16BB8850
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 21:00:59 +0100 (IST)
Date: Tue, 5 Jun 2018 21:00:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
Message-ID: <20180605200058.fy4oy5znf6j4pckj@techsingularity.net>
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
 <bfc2e579-915f-24db-0ff0-29bd9148b8c0@intel.com>
 <20180605191245.3owve7gfut22tyob@techsingularity.net>
 <ecb75c29-3d1b-3b5e-ec9d-59c4f6c1ef08@intel.com>
 <20180605195140.afc7xzgbre26m76l@techsingularity.net>
 <9dc03a4b-d359-8817-a950-b98e246dcd95@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9dc03a4b-d359-8817-a950-b98e246dcd95@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 05, 2018 at 12:54:27PM -0700, Dave Hansen wrote:
> On 06/05/2018 12:51 PM, Mel Gorman wrote:
> > Using another testcase that simply calls mremap heavily with varying number
> > of threads, it was found that very broadly speaking that TLB shootdowns
> > were reduced by 31% on average throughout the entire test case but your
> > milage will vary.
> 
> Looks good to me.  Feel free to add my Reviewed-by.

Thanks, I'll send a proper v2 when I hear back from the customer on what
the impact on the real workload is.

-- 
Mel Gorman
SUSE Labs
