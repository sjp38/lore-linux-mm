Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3620A6B0032
	for <linux-mm@kvack.org>; Sun, 25 Jan 2015 04:25:26 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x12so4357917wgg.7
        for <linux-mm@kvack.org>; Sun, 25 Jan 2015 01:25:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si13074596wiw.38.2015.01.25.01.25.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 25 Jan 2015 01:25:24 -0800 (PST)
Message-ID: <54C4B680.3010304@suse.cz>
Date: Sun, 25 Jan 2015 10:25:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com> <20150123191816.GN11755@redhat.com>
In-Reply-To: <20150123191816.GN11755@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com

On 23.1.2015 20:18, Andrea Arcangeli wrote:
>> >+		if (!pte_write(pteval)) {
>> >+			if (++ro > khugepaged_max_ptes_none)
>> >+				goto out_unmap;
>> >+		}
> It's true this is maxed out at 511, so there must be at least one
> writable and not none pte (as results of the two "ro" and "none"
> counters checks).

Hm, but if we consider ro and pte_none separately, both can be lower
than 512, but the sum of the two can be 512, so we can actually be in
read-only VMA?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
