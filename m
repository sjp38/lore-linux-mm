Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id CDAD082997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 05:27:19 -0400 (EDT)
Received: by wibt6 with SMTP id t6so40812590wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:27:19 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gc5si289742wib.61.2015.05.22.02.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 02:27:18 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so41104908wic.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:27:17 -0700 (PDT)
Date: Fri, 22 May 2015 11:27:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-4.0 317/333] include/ras/ras_event.h:282:1: error:
 type defaults to 'int' in declaration of 'TRACE_DEFINE_ENUM'
Message-ID: <20150522092716.GC5109@dhcp22.suse.cz>
References: <201505220002.VctG5ir8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505220002.VctG5ir8%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, kbuild-all@01.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri 22-05-15 00:21:05, Wu Fengguang wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.0

OK, my tree was missing another two patches from a different tree:
acd388fd3af350ab24c6ab6f19b83fc4a4f3aa60
0c564a538aa934ad15b2145aaf8b64f3feb0be63

I am wondering why this wasn't caught during my compile testing before
the last mmotm version went out... Fixed and I will push it shortly.

Thanks and sorry for the noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
