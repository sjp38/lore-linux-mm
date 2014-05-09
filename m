Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id D57D26B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 12:34:07 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id r5so4817308qcx.7
        for <linux-mm@kvack.org>; Fri, 09 May 2014 09:34:07 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id e4si2268518qcc.11.2014.05.09.09.34.06
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 09:34:07 -0700 (PDT)
Date: Fri, 9 May 2014 11:34:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: use a irq-safe __mod_zone_page_state in
 mlocked_vma_newpage()
In-Reply-To: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Message-ID: <alpine.DEB.2.10.1405091133360.11810@gentwo.org>
References: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, zhangyanfei@cn.fujitsu.com, hanpt@linux.vnet.ibm.com, sasha.levin@oracle.com, oleg@redhat.com, fabf@skynet.be, mgorman@suse.de, aarcange@redhat.com, cldu@marvell.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 May 2014, Jianyu Zhan wrote:

> Hi, Christoph, I'm sorry for the misleading phrasing.
> Would be this one OK? Thanks.

Good.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
