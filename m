Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 255FF6B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:19:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so18244975wry.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:19:13 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id t3si7329598wmd.79.2017.03.01.07.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 07:19:11 -0800 (PST)
Date: Wed, 1 Mar 2017 07:19:10 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
Message-ID: <20170301151910.GH26852@two.firstfloor.org>
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org

> - Even if the default maximum size is reduced the size of these
> tables should still be tunable, as it really depends on the way
> machine is used, and in it is possible that for some use patterns
> large hash tables are necessary.

I consider it very unlikely that a 8G dentry hash table ever makes
sense. I cannot even imagine a workload where you would have that
many active files. It's just a bad configuration that should be avoided.

And when the tables are small enough you don't need these hacks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
