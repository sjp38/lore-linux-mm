Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29E436B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 10:31:06 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v190so2256725pgv.11
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 07:31:06 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id e3si2108050pgp.89.2017.12.06.07.31.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 07:31:04 -0800 (PST)
Subject: Re: [PATCH] mm: Export unmapped_area*() functions
References: <1512486927-32349-1-git-send-email-hareeshg@codeaurora.org>
 <20171205152944.GA10573@lst.de>
From: Hareesh Gundu <hareeshg@codeaurora.org>
Message-ID: <d5c9b199-7379-f6e1-d5a4-f072d7f9cd93@codeaurora.org>
Date: Wed, 6 Dec 2017 21:00:57 +0530
MIME-Version: 1.0
In-Reply-To: <20171205152944.GA10573@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, jcrouse@codeaurora.org

On 12/5/2017 8:59 PM, Christoph Hellwig wrote:
> On Tue, Dec 05, 2017 at 08:45:27PM +0530, Hareesh Gundu wrote:
>> Add EXPORT_SYMBOL to unmapped_area()
>> and unmapped_area_topdown(). So they
>> are usable from modules.
This change is not for in-tree kernel module. It's for modules built 
outside of kernel tree modules.
> Please send this along with the actual modules.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
