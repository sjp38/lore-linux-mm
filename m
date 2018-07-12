Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBA596B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 21:46:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i123-v6so9406762pfc.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:46:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r81-v6si22062087pfg.305.2018.07.11.18.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 18:46:57 -0700 (PDT)
Date: Wed, 11 Jul 2018 18:46:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm, page_alloc: double zone's batchsize
Message-Id: <20180711184655.23638dfdc29f57c6b70732f4@linux-foundation.org>
In-Reply-To: <9f778198327e62cdab0651382740189e0665507a.camel@intel.com>
References: <20180711055855.29072-1-aaron.lu@intel.com>
	<20180711143505.5ccb378fb67dc6ba8fa202a3@linux-foundation.org>
	<9f778198327e62cdab0651382740189e0665507a.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lu, Aaron" <aaron.lu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "Wang, Kemi" <kemi.wang@intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "Hansen, Dave" <dave.hansen@intel.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "Huang, Ying" <ying.huang@intel.com>

On Thu, 12 Jul 2018 01:40:41 +0000 "Lu, Aaron" <aaron.lu@intel.com> wrote:

> Thanks Andrew.
> I think the credit goes to Dave Hansen

Oh.  In that case, I take it all back.  The patch sucks!
