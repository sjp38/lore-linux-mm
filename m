Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFC56B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:23:38 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so7626712pde.14
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 19:23:37 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id pi8si13191417pac.30.2013.12.17.19.23.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 19:23:36 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 13:23:33 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0F38C3578053
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:23:32 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI3NJDH66060474
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:23:19 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI3NV9C026175
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:23:31 +1100
Date: Wed, 18 Dec 2013 11:23:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52b11538.c8da420a.0f99.ffffdd4cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 18, 2013 at 11:16:19AM +0800, Wanpeng Li wrote:
>On Tue, Dec 17, 2013 at 04:05:50PM +0800, Wanpeng Li wrote:
>
>Another alternative method to fix this bug.

Sorry for the wrong version. 

--uAKRQypu60I7Lcqm
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-2.patch"


--uAKRQypu60I7Lcqm--
