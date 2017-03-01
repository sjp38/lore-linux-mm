Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB936B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 19:24:30 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so35707706pga.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:24:30 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i5si3079544pgh.191.2017.02.28.16.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 16:24:28 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
	<1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
Date: Tue, 28 Feb 2017 16:24:28 -0800
In-Reply-To: <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
	(Pavel Tatashin's message of "Tue, 28 Feb 2017 19:14:41 -0500")
Message-ID: <87h93dhmir.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org

Pavel Tatashin <pasha.tatashin@oracle.com> writes:
>
> While investigating how to improve initialization time of dentry_hashtable
> which is 8G long on M6 ldom with 7T of main memory, I noticed that memset()

I don't think a 8G dentry (or other kernel) hash table makes much
sense. I would rather fix the hash table sizing algorithm to have some
reasonable upper limit than to optimize the zeroing.

I believe there are already boot options for it, but it would be better
if it worked out of the box.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
