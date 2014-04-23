Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5AB6B0037
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:18:41 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1060382eek.31
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:18:40 -0700 (PDT)
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
        by mx.google.com with ESMTPS id r9si4306566eew.288.2014.04.23.11.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 11:18:40 -0700 (PDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1045375eei.5
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:18:39 -0700 (PDT)
Message-ID: <535803FC.1040605@colorfullife.com>
Date: Wed, 23 Apr 2014 20:18:36 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
> -  Breakup long function names/args.
> -  Cleaup variable declaration.
s/Cleaup/Cleanup/
> -  s/current->mm/mm
>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

> @@ -681,7 +679,8 @@ copy_shmid_from_user(struct shmid64_ds *out, void __user *buf, int version)
>   	}
>   }
>   
> -static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminfo64 *in, int version)
> +static inline unsigned long copy_shminfo_to_user(void __user *buf,
> +						 struct shminfo64 *in, int version)
Checkpatch still complains - does removing one tab help?

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
