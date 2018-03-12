Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64C176B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:22:55 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e78so4360679oib.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 03:22:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o125si1868339oif.282.2018.03.12.03.22.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Mar 2018 03:22:53 -0700 (PDT)
Subject: Re: KVM hang after OOM
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b9ef3b5f-37c2-649a-2c90-8fbbf2bd3bed@i-love.sakura.ne.jp>
Date: Mon, 12 Mar 2018 19:22:39 +0900
MIME-Version: 1.0
In-Reply-To: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 2018/03/12 3:11, Mikhail Gavrilov wrote:
> $ uname -a
> Linux localhost.localdomain 4.15.7-300.fc27.x86_64+debug #1 SMP Wed
> Feb 28 17:32:16 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
>
>
> How reproduce:
> 1. start virtual machine
> 2. open https://oom.sy24.ru/ in Firefox which will helps occurred OOM.
> Sorry I can't attach here html page because my message will rejected
> as message would contained HTML subpart.
>
> Actual result virtual machine hang and even couldn't be force off.
>
> Expected result virtual machine continue work.

Looks like similar problem with http://lkml.kernel.org/r/20180212124359.GB3443@dhcp22.suse.cz .
We are waiting for Michal Hocko to come back.
