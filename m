Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEA2280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 22:07:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t126so91357563pgc.9
        for <linux-mm@kvack.org>; Sat, 20 May 2017 19:07:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m63si13021513pfa.331.2017.05.20.19.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 19:07:30 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
	<1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
Date: Sat, 20 May 2017 19:07:29 -0700
In-Reply-To: <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
	(Pavel Tatashin's message of "Sat, 20 May 2017 13:06:53 -0400")
Message-ID: <87h90faroe.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

Pavel Tatashin <pasha.tatashin@oracle.com> writes:

> Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
> is provided every time memory quadruples the sizes of hash tables will only
> double instead of quadrupling as well. This algorithm starts working only
> when memory size reaches a certain point, currently set to 64G.
>
> This is example of dentry hash table size, before and after four various
> memory configurations:

IMHO the scale is still too aggressive. I find it very unlikely
that a 1TB machine really needs 256MB of hash table because
number of used files are unlikely to directly scale with memory.

Perhaps should just cap it at some large size, e.g. 32M

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
