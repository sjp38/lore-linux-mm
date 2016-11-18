Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D98D6B0482
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:08:47 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 34so173614361uac.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:08:47 -0800 (PST)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id c4si2670240vkh.3.2016.11.18.14.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 14:08:46 -0800 (PST)
Received: by mail-vk0-x231.google.com with SMTP id w194so178938391vkw.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:08:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <OF4C17DCE5.3A69F6D5-ON4825806F.00234EAD-4825806F.00238F1A@notes.na.collabserv.com>
References: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
 <20161104152103.GC8825@cmpxchg.org> <5b03def0-2dc4-842f-0d0e-53cc2d94936f@gmail.com>
 <OF4C17DCE5.3A69F6D5-ON4825806F.00234EAD-4825806F.00238F1A@notes.na.collabserv.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 19 Nov 2016 09:08:45 +1100
Message-ID: <CAKTCnz=ywwA4gYmdSGSksxH0qYkLpXob5DwvWWZJ0_mvAVBWwA@mail.gmail.com>
Subject: Re: memory.force_empty is deprecated
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhao Hui Ding <dingzhh@cn.ibm.com>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>

On Fri, Nov 18, 2016 at 5:28 PM, Zhao Hui Ding <dingzhh@cn.ibm.com> wrote:
> Thank you.
> Do you mean memory.force_empty won't be deprecated and removed?
>
> Regards,
> --Zhaohui

No I am not implying that. That is decided by the maintainers.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
