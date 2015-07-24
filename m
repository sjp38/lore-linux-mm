Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 430629003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 02:25:39 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so14063347wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 23:25:38 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id fr8si2540789wib.3.2015.07.23.23.25.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 23:25:37 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so14062552wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 23:25:37 -0700 (PDT)
Date: Fri, 24 Jul 2015 08:25:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 PATCH 8/9] hugetlbfs: add hugetlbfs_fallocate()
Message-ID: <20150724062533.GA4622@dhcp22.suse.cz>
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
 <1435019919-29225-9-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1435019919-29225-9-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

I hope this is the current version of the pathc - I somehow got lost in
last submissions where the discussion happens in v4 thread. This version
seems to have the same issue:
---
