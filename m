Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA2A6B0006
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:21:12 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id h61-v6so1108148pld.3
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 00:21:12 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0124.outbound.protection.outlook.com. [104.47.2.124])
        by mx.google.com with ESMTPS id b9-v6si946819pll.117.2018.02.28.00.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Feb 2018 00:21:10 -0800 (PST)
Subject: Re: [PATCH 3/3] userfaultfd: non-cooperative: allow synchronous
 EVENT_REMOVE
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1519719592-22668-4-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <1a2ed216-74ac-5fe2-abff-21d670eeb96d@virtuozzo.com>
Date: Wed, 28 Feb 2018 11:21:02 +0300
MIME-Version: 1.0
In-Reply-To: <1519719592-22668-4-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>


> @@ -52,6 +53,7 @@
>  #define _UFFDIO_WAKE			(0x02)
>  #define _UFFDIO_COPY			(0x03)
>  #define _UFFDIO_ZEROPAGE		(0x04)
> +#define _UFFDIO_WAKE_SYNC_EVENT		(0x05)

Excuse my ignorance, but what's the difference between UFFDIO_WAKE and UFFDIO_WAKE_SYNC_EVENT?

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
