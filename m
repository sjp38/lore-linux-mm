Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 392C36B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:16:29 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so5326542pab.7
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 19:16:28 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id bc2si13140627pad.129.2013.12.17.19.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 19:16:27 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 08:46:24 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 65B7A3940023
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:46:21 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI3GIcD5570854
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:46:18 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI3GKhN002674
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:46:20 +0530
Date: Wed, 18 Dec 2013 11:16:19 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Content-Disposition: inline
In-Reply-To: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 17, 2013 at 04:05:50PM +0800, Wanpeng Li wrote:

Another alternative method to fix this bug.

--huq684BweRXVnRxX
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-2.patch"


--huq684BweRXVnRxX--
