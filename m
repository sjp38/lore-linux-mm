Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 71A1B6B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:16:39 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so194631984pac.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:16:39 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id fm7si24574526pab.81.2015.05.05.07.16.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 07:16:35 -0700 (PDT)
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3509220DC0
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:16:32 -0400 (EDT)
Message-ID: <5548D0BD.3080602@iki.fi>
Date: Tue, 05 May 2015 17:16:29 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] perf kmem: Show warning when trying to run stat without
 record
References: <20150504161539.GG10475@kernel.org> <1430787492-6893-1-git-send-email-namhyung@kernel.org> <20150505140706.GJ10475@kernel.org>
In-Reply-To: <20150505140706.GJ10475@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>, Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On 05/05/2015 05:07 PM, Arnaldo Carvalho de Melo wrote:
> Em Tue, May 05, 2015 at 09:58:12AM +0900, Namhyung Kim escreveu:
>> Sometimes one can mistakenly run perf kmem stat without perf kmem
>> record before or different configuration like recoding --slab and stat
>> --page.  Show a warning message like below to inform user:
>>
>>    # perf kmem stat --page --caller
>>    Not found page events.  Have you run 'perf kmem record --page' before?
>>
>> Acked-by: Pekka Enberg <penberg@kernel.org>
>> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> Thanks, applied.
>
> I just found the messages a bit odd souding, perhaps:
>
>     # perf kmem stat --page --caller
>     No page allocation events found.  Have you run 'perf kmem record --page'?
>
> Pekka?

Sure, that sounds less confusing.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
