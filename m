Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80D836B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 09:30:54 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i185so214954591ywg.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:30:54 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id a125si2374780qkd.149.2016.06.03.06.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 06:30:53 -0700 (PDT)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 07:30:52 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/3] mm/hugetlb: Simplify hugetlb unmap
In-Reply-To: <1464959359-7543-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464959359-7543-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Fri, 03 Jun 2016 19:00:33 +0530
Message-ID: <87bn3iwgau.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


Hi Andrew,

The updated version includes a build fix for [PATCH 2/3. I also dropped the
powerpc related changes from the series because that have dependencies
against other patches not yet merged upstream. I am adding the same
below for reference.
