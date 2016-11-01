Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 834526B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:24:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l124so92536636wml.4
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:24:16 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id f70si32165142wmg.26.2016.11.01.10.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:24:15 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id u144so4386117wmu.0
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:24:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Tue, 1 Nov 2016 20:23:54 +0300
Message-ID: <CAJwJo6Z9qXbYb3RHL89Z2JPJWc6biOt54sWcHXeNwD5dDxQXjQ@mail.gmail.com>
Subject: Re: [RFC v2 1/7] mm: Provide generic VDSO unmap and remap functions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>
Cc: crml <criu@openvz.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, open list <linux-kernel@vger.kernel.org>

Hi Christopher,

  by this moment I got another patch for this. I hope, you don't mind
if I send it concurrently. I haven't sent it yet as I was testing it in qemu.

Thanks,
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
