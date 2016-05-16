Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 889606B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 12:24:46 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id sq19so185324816igc.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 09:24:46 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-eopbgr00119.outbound.protection.outlook.com. [40.107.0.119])
        by mx.google.com with ESMTPS id e12si1670491otd.48.2016.05.16.09.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 May 2016 09:24:45 -0700 (PDT)
Subject: Re: [PATCHv8 resend 1/2] x86/vdso: add mremap hook to
 vm_special_mapping
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <79f9fe67-a343-43b8-0933-a79461900c1b@virtuozzo.com>
 <20160516105429.GA20440@gmail.com>
 <d7ae8fe4-2177-8dc0-6087-bb64d74907f9@virtuozzo.com>
 <20160516135522.GB14452@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <1432af28-6be2-6d7f-2e21-a7da0c2dfe57@virtuozzo.com>
Date: Mon, 16 May 2016 19:23:29 +0300
MIME-Version: 1.0
In-Reply-To: <20160516135522.GB14452@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com

On 05/16/2016 04:55 PM, Ingo Molnar wrote:
>
>
> Ok, this looks useful - please add this information to the changelog (with typos
> fixed).

Thanks will add to v9.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
