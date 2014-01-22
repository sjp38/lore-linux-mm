Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEC56B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:18:27 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id d10so1696584eaj.4
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:18:27 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id h45si16729255eeo.46.2014.01.22.03.18.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:18:27 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Wed, 22 Jan 2014 11:18:26 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B7EB217D805C
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:18:40 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0MBICRp524550
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:18:12 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0MBINJC009433
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:18:24 -0700
Date: Wed, 22 Jan 2014 12:18:21 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V5 2/3] mm/memblock: Add support for excluded memory
 areas
Message-ID: <20140122121821.6da53a02@lilie>
In-Reply-To: <1390217559-14691-3-git-send-email-phacht@linux.vnet.ibm.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1390217559-14691-3-git-send-email-phacht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi again,

I'd like to remind that the s390 development relies on this patch
(and the next one, for cleanliness, of course) being added. It would be
very good to see it being added to the -mm tree resp. linux-next.

Kind regards

Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
