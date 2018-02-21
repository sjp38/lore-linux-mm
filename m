Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 023A26B0009
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:14:42 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g13so2153421wrh.23
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:14:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si17576198wmf.129.2018.02.21.11.14.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 11:14:40 -0800 (PST)
Date: Wed, 21 Feb 2018 20:14:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] hugetlb: fix surplus pages accounting
Message-ID: <20180221191439.GM2231@dhcp22.suse.cz>
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103093213.26329-6-mhocko@kernel.org>
 <20180221042457.uolmhlmv5je5dqx7@xps>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221042457.uolmhlmv5je5dqx7@xps>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Rue <dan.rue@linaro.org>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

OK, so here we go with the fix.
