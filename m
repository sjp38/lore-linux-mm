Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 496B26B0031
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 03:44:43 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id q200so2800486ykb.28
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 00:44:43 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n42si8864562yho.131.2014.06.14.00.44.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 00:44:42 -0700 (PDT)
Message-ID: <539BFD5E.4060907@oracle.com>
Date: Sat, 14 Jun 2014 15:44:30 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
References: <5399A360.3060309@oracle.com> <CAOJsxLFyNZ9dc5T7282eqsg6gPtST75_h-5iGLX=t6OsWAPSCw@mail.gmail.com>
In-Reply-To: <CAOJsxLFyNZ9dc5T7282eqsg6gPtST75_h-5iGLX=t6OsWAPSCw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>


On 06/13/2014 14:57 PM, Pekka Enberg wrote:
> On Thu, Jun 12, 2014 at 3:56 PM, Jeff Liu <jeff.liu@oracle.com> wrote:
>> From: Jie Liu <jeff.liu@oracle.com>
>>
>> Return ENOMEM instead of ENOSYS if slab_sysfs_init() failed
>>
>> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
>> ---
>>  mm/slub.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 2b1ce69..75ca109 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -5304,7 +5304,7 @@ static int __init slab_sysfs_init(void)
>>         if (!slab_kset) {
>>                 mutex_unlock(&slab_mutex);
>>                 printk(KERN_ERR "Cannot register slab subsystem.\n");
>> -               return -ENOSYS;
>> +               return -ENOMEM;
> 
> What is the motivation for this change? AFAICT, kset_create_and_add()
> can fail for other reasons than ENOMEM, no?

Originally I'd like to make it consistent to most other subsystems which are
return ENOMEM in case of sysfs init failed, but yes, kset_register() can fail
due to different reaons...


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
