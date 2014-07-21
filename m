Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE676B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:51:07 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so9689093pde.23
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:51:06 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ik3si15208491pbc.249.2014.07.21.12.51.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 12:51:06 -0700 (PDT)
Message-ID: <53CD6F28.3080203@codeaurora.org>
Date: Mon, 21 Jul 2014 12:51:04 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv4 2/5] lib/genalloc.c: Add genpool range check function
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>	<1404324218-4743-3-git-send-email-lauraa@codeaurora.org> <CAOesGMiKBNDmJhiY-yK0uZmG-MnK82=ffNGxqasLKozqgpQQpw@mail.gmail.com>
In-Reply-To: <CAOesGMiKBNDmJhiY-yK0uZmG-MnK82=ffNGxqasLKozqgpQQpw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 7/9/2014 3:33 PM, Olof Johansson wrote:
> On Wed, Jul 2, 2014 at 11:03 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
>>
>> After allocating an address from a particular genpool,
>> there is no good way to verify if that address actually
>> belongs to a genpool. Introduce addr_in_gen_pool which
>> will return if an address plus size falls completely
>> within the genpool range.
>>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> 
> Reviewed-by: Olof Johansson <olof@lixom.net>
> 
> What's the merge path for this code? Part of the arm64 code that needs
> it, I presume?
> 

My plan was to have the entire series go through the arm64 tree unless
someone has a better idea.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
