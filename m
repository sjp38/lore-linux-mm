Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3821B6B0275
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:41:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so156414304pgc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 08:41:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w8si32542683pgw.107.2016.11.16.08.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 08:41:05 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAGGdTHl069587
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:41:04 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26rnseh9ed-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:41:04 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 16 Nov 2016 09:41:03 -0700
Date: Wed, 16 Nov 2016 10:40:57 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RESEND] [PATCH v1 3/3] powerpc: fix node_possible_map
 limitations
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
 <1479253501-26261-4-git-send-email-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1479253501-26261-4-git-send-email-bsingharora@gmail.com>
Message-Id: <20161116164057.mzlhfigsuwn53r72@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 16, 2016 at 10:45:01AM +1100, Balbir Singh wrote:
>Reverts: commit 3af229f2071f
>("powerpc/numa: Reset node_possible_map to only node_online_map")

Nice! With this limitation going away, I have a small patch to enable 
onlining new nodes via memory hotplug. Incoming.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
