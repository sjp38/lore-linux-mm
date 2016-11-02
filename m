Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96ACD6B02B9
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 20:23:08 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rt15so41332pab.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 17:23:08 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 3si33192923pfd.50.2016.11.01.17.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 17:23:07 -0700 (PDT)
In-Reply-To: <CAJwJo6Z9qXbYb3RHL89Z2JPJWc6biOt54sWcHXeNwD5dDxQXjQ@mail.gmail.com>
References: <20161101171101.24704-1-cov@codeaurora.org> <CAJwJo6Z9qXbYb3RHL89Z2JPJWc6biOt54sWcHXeNwD5dDxQXjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC v2 1/7] mm: Provide generic VDSO unmap and remap functions
From: Christopher Covington <cov@codeaurora.org>
Date: Tue, 01 Nov 2016 18:23:01 -0600
Message-ID: <B6819DB6-D247-43CC-AB51-D08EC5EEFB5B@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: crml <criu@openvz.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, open list <linux-kernel@vger.kernel.org>



On November 1, 2016 11:23:54 AM MDT, Dmitry Safonov <0x7f454c46@gmail.com> wrote:
>Hi Christopher,
>
>  by this moment I got another patch for this. I hope, you don't mind
>if I send it concurrently. I haven't sent it yet as I was testing it in
> qemu.

Please do, that'd be great.

Thanks, 
Cov

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.

Sent from my Snapdragon powered Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
