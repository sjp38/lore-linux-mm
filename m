Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6DE46B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:58:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v66so10511413wrc.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:58:50 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id l78si239953wmg.72.2017.03.16.13.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 13:58:49 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id g10so7363257wrg.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:58:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316162402.rpkulrjcjoxzzlw4@arbab-laptop>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com> <20170316162402.rpkulrjcjoxzzlw4@arbab-laptop>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 17 Mar 2017 07:58:48 +1100
Message-ID: <CAKTCnzkpfvUB6xBwxURTHABp7cpTrq_zJaK9Km1YRrPH6LK82A@mail.gmail.com>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Mar 17, 2017 at 3:24 AM, Reza Arbab <arbab@linux.vnet.ibm.com> wrot=
e:
> On Thu, Mar 16, 2017 at 12:05:26PM -0400, J=C3=A9r=C3=B4me Glisse wrote:
>>
>> This patch add a new memory migration helpers, which migrate memory
>> backing a range of virtual address of a process to different memory (whi=
ch
>> can be allocated through special allocator). It differs from numa migrat=
ion
>> by working on a range of virtual address and thus by doing migration in
>> chunk that can be large enough to use DMA engine or special copy offload=
ing
>> engine.
>
>
> Reviewed-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>
>


Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
