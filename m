Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 93F7F828F3
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 02:14:04 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id qe11so23140951lbc.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:14:04 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id at10si515755lbc.4.2016.04.05.23.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 23:14:03 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id o124so3344734lfb.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:14:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56EFC4F2.2050104@virtuozzo.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
	<56EFC4F2.2050104@virtuozzo.com>
Date: Wed, 6 Apr 2016 09:14:02 +0300
Message-ID: <CABpLfohK14xp-pOcAhOsGWeHuAzSySypVTj_RzUQDm-9M3s67w@mail.gmail.com>
Subject: Re: [PATCH 0/5] userfaultfd: extension for non cooperative uffd usage
From: Mike Rapoport <mike.rapoport@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rapoport@il.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Mar 21, 2016 at 11:54 AM, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
> On 03/20/2016 03:42 PM, Mike Rapoport wrote:
>> Hi,
>>
>> This set is to address the issues that appear in userfaultfd usage
>> scenarios when the task monitoring the uffd and the mm-owner do not
>> cooperate to each other on VM changes such as remaps, madvises and
>> fork()-s.
>>
>> The pacthes are essentially the same as in the prevoious respin (1),
>> they've just been rebased on the current tree.
>>
>> [1] http://thread.gmane.org/gmane.linux.kernel.mm/132662
>
> Thanks, Mike!
>
> Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
>

Any updates/comments on this?

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
