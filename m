Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2779A6B797F
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 11:58:52 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d11-v6so4073547ybj.1
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:58:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x82-v6si1414605ywc.547.2018.09.06.08.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 08:58:51 -0700 (PDT)
Date: Thu, 6 Sep 2018 08:58:14 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small
 number of objects
Message-ID: <20180906155811.GA25424@tower.DHCP.thefacebook.com>
References: <20180904224707.10356-1-guro@fb.com>
 <201809061523.HXrJKywf%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201809061523.HXrJKywf%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 06, 2018 at 03:42:07PM +0800, kbuild test robot wrote:
> Hi Roman,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.19-rc2 next-20180905]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

Thanks for the report!

The issue has been fixed in v3, which I sent yesterday.

Thanks,
Roman
