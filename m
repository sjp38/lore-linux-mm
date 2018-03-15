Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDC4E6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 14:51:21 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id k4-v6so3690313pls.15
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:51:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor1691941pfj.55.2018.03.15.11.51.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 11:51:20 -0700 (PDT)
Subject: Re: [PATCH 4/8] struct page: add field for vm_struct
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-5-igor.stoppa@huawei.com>
 <20180313220040.GA15791@bombadil.infradead.org>
 <7b18521c-539b-2ba1-823e-e83be071c13f@gmail.com>
 <6924c919-dbfb-a9f6-748a-0bbfe8d876b1@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <007b20f7-54f8-0397-88ce-4a106bfdb8e9@gmail.com>
Date: Thu, 15 Mar 2018 11:51:16 -0700
MIME-Version: 1.0
In-Reply-To: <6924c919-dbfb-a9f6-748a-0bbfe8d876b1@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 3/15/18 2:38 AM, Igor Stoppa wrote:
> On 14/03/18 19:43, J Freyensee wrote:
>> On 3/13/18 3:00 PM, Matthew Wilcox wrote:
> [...]
>
>>>> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
>>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>> Igor, do you mind sticking these tags on the files that have spent some
>> time reviewing a revision of your patchset (like the Reviewed-by: tags I
>> provided last revision?)
> Apologies, that was not intentional, I forgot it.
> I will do it, although most of the files will now change so much that I
> am not sure what will survive, beside this patch, in the form that you
> reviewed.
>
> I suppose the Review-by tag drops, if the patch changes.

That's true, if so much of the patch changes it basically looks like 
something different, the Reviewed-by: would drop.

Jay

>
> --
> igor
