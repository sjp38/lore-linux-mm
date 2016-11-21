Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81B826B04BC
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 20:50:01 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so369419584pgx.6
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 17:50:01 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r62si15567611pgr.192.2016.11.20.17.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 17:50:00 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 3so26953986pgd.0
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 17:50:00 -0800 (PST)
Subject: Re: [HMM v13 04/18] mm/ZONE_DEVICE/free-page: callback when page is
 freed
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-5-git-send-email-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <7ec714d6-6779-5abf-0607-862acddfbd4a@gmail.com>
Date: Mon, 21 Nov 2016 12:49:55 +1100
MIME-Version: 1.0
In-Reply-To: <1479493107-982-5-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>



On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
> When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
> is holding a reference on it (only device to which the memory belong do).
> Add a callback and call it when that happen so device driver can implement
> their own free page management.
> 

Could you give an example of what their own free page management might look like?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
