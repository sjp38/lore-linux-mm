Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id B067B6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 01:38:32 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so1409474eei.28
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 22:38:31 -0700 (PDT)
Received: from mail-ee0-x22c.google.com (mail-ee0-x22c.google.com [2a00:1450:4013:c00::22c])
        by mx.google.com with ESMTPS id d5si6605107eei.268.2014.04.23.22.38.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 22:38:30 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1369951eek.17
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 22:38:30 -0700 (PDT)
Message-ID: <53589E8E.1040000@gmail.com>
Date: Thu, 24 Apr 2014 07:18:06 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>	 <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>	 <53574AA5.1060205@gmail.com> <1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com, Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/23/2014 07:25 AM, Davidlohr Bueso wrote:
> On Wed, 2014-04-23 at 07:07 +0200, Michael Kerrisk (man-pages) wrote:
>> On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
>>> -  Breakup long function names/args.
>>> -  Cleaup variable declaration.
>>> -  s/current->mm/mm
>>>
>>> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
>>> ---
>>>  ipc/shm.c | 40 +++++++++++++++++-----------------------
>>>  1 file changed, 17 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/ipc/shm.c b/ipc/shm.c
>>> index f000696..584d02e 100644
>>> --- a/ipc/shm.c
>>> +++ b/ipc/shm.c
>>> @@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_vm_ops = {
>>>  static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>>>  {
>>>  	key_t key = params->key;
>>> -	int shmflg = params->flg;
>>> +	int id, error, shmflg = params->flg;
>>
>> It's largely a matter of taste (and I may be in a minority), and I know
>> there's certainly precedent in the kernel code, but I don't much like the 
>> style of mixing variable declarations that have initializers, with other
>> unrelated declarations (e.g., variables without initializers). What is 
>> the gain? One less line of text? That's (IMO) more than offset by the 
>> small loss of readability.
> 
> Yes, it's taste. And yes, your in the minority, at least in many core
> kernel components and ipc.

Davidlohr,

So, noting that the minority is less small than we thought, I'll just
add this: I'd have appreciated it if your reply had been less 
dismissive, and you'd actually responded to my concrete point about 
loss of readability.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
