Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 134316B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 12:02:14 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 64so28776370ior.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:02:14 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id t18si4665085pfi.234.2016.10.11.09.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 09:02:13 -0700 (PDT)
Message-ID: <57FD0CF8.2030208@windriver.com>
Date: Tue, 11 Oct 2016 10:02:00 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: "swap_free: Bad swap file entry" and "BUG: Bad page map in process"
 but no swap configured
References: <57F6BB8F.7070208@windriver.com> <018601d2213a$bb0e44e0$312acea0$@alibaba-inc.com>
In-Reply-To: <018601d2213a$bb0e44e0$312acea0$@alibaba-inc.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'lkml' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 10/08/2016 02:05 AM, Hillf Danton wrote:
> On Friday, October 07, 2016 5:01 AM Chris Friesen
>>
>> I have Linux host running as a kvm hypervisor.  It's running CentOS.  (So the
>> kernel is based on 3.10 but with loads of stuff backported by RedHat.)  I
>> realize this is not a mainline kernel, but I was wondering if anyone is aware of
>> similar issues that had been fixed in mainline.
>>
> Hey, dunno if you're looking for commit
> 	6dec97dc929 ("mm: move_ptes -- Set soft dirty bit depending on pte type")
> Hillf

CONFIG_MEM_SOFT_DIRTY doesn't exist in our kernel so I don't think this is the 
issue.  Thanks for the suggestion though.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
