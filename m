Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 03DF06B0038
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 02:55:38 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so888714pab.32
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:55:38 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id if17so530828vcb.4
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:55:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5243D8FA.9090404@suse.cz>
References: <20130926004028.GB9394@localhost>
	<5243D8FA.9090404@suse.cz>
Date: Thu, 26 Sep 2013 14:55:36 +0800
Message-ID: <CAA_GA1d=y31SqLBZGhXXwf3yJnqeTkLW0bNOOV=2mvZ+1C0nHg@mail.gmail.com>
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:cf17e720 pmd:05a22067
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 26, 2013 at 2:49 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/26/2013 02:40 AM, Fengguang Wu wrote:
>> Hi Vlastimil,
>>
>> FYI, this bug seems still not fixed in linux-next 20130925.
>
> Hi,
>
> I sent (including you) a RFC patch and later reviewed patch about week
> ago. I assumed you would test it, but I probably should make that
> request explicit, sorry. Anyway it was added to -mm an hour before your
> mail.
>

Great! And please ignore my noise in this thread.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
