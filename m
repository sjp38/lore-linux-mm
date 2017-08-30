Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7596B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:46:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so13468584pgt.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:46:13 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id u126si4878387pgb.366.2017.08.30.10.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 10:46:12 -0700 (PDT)
Date: Wed, 30 Aug 2017 10:46:08 -0700 (PDT)
Message-Id: <20170830.104608.2080967179463692935.davem@davemloft.net>
Subject: Re: [PATCH v7 07/11] sparc64: optimized struct page zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <e07c05b1-c0be-bf7f-9a29-11dc41b79d10@oracle.com>
References: <1503972142-289376-8-git-send-email-pasha.tatashin@oracle.com>
	<20170829.181208.171985548699678313.davem@davemloft.net>
	<e07c05b1-c0be-bf7f-9a29-11dc41b79d10@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

From: Pasha Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 30 Aug 2017 09:19:58 -0400

> The reason I am not doing initializing stores is because they require
> a membar, even if only regular stores are following (I hoped to do a
> membar before first load). This is something I was thinking was not
> true, but after consulting with colleagues and checking processor
> manual, I verified that it is the case.

Oh yes, that's right, now I remember.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
