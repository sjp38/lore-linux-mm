Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB2B6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 23:10:45 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 32so185880ots.15
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 20:10:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q38si7143774otd.8.2018.11.11.20.10.44
        for <linux-mm@kvack.org>;
        Sun, 11 Nov 2018 20:10:44 -0800 (PST)
Subject: Re: [RFC] mm: Replace all open encodings for NUMA_NO_NODE
References: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
 <1e9393c5-ff43-8ec7-dd6c-a662f09ef7c1@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b92e3275-7a04-a148-bb5b-38658c270583@arm.com>
Date: Mon, 12 Nov 2018 09:40:39 +0530
MIME-Version: 1.0
In-Reply-To: <1e9393c5-ff43-8ec7-dd6c-a662f09ef7c1@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joseph Qi <jiangqi903@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org



On 11/12/2018 09:27 AM, Joseph Qi wrote:
> For ocfs2 part, node means host in the cluster, not NUMA node.
> 

Does not -1 indicate an invalid node which can never be present ?
