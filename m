Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 402706B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 11:16:07 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id k13so11535427iea.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2013 08:16:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFFWPChApkuec17Z09Z11OS5Q+XSHo4U4mSc754dC1-ww@mail.gmail.com>
References: <1358848018-3679-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<CAOJsxLFFWPChApkuec17Z09Z11OS5Q+XSHo4U4mSc754dC1-ww@mail.gmail.com>
Date: Tue, 22 Jan 2013 13:16:06 -0300
Message-ID: <CALF0-+X2MT4TueY5=NF8pp=orUd9nS0Tm2nQgwzxo1xstri-mQ@mail.gmail.com>
Subject: Re: [RFC/PATCH] scripts/tracing: Add trace_analyze.py tool
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi Pekka,

On Tue, Jan 22, 2013 at 10:41 AM, Pekka Enberg <penberg@kernel.org> wrote:
> (Adding acme to CC.)
>
> On Tue, Jan 22, 2013 at 11:46 AM, Ezequiel Garcia
> <ezequiel.garcia@free-electrons.com> wrote:
>> From: Ezequiel Garcia <elezegarcia@gmail.com>
>>
>> The purpose of trace_analyze.py tool is to perform static
>> and dynamic memory analysis using a kmem ftrace
>> log file and a built kernel tree.
>>
>> This script and related work has been done on the CEWG/2012 project:
>> "Kernel dynamic memory allocation tracking and reduction"
>> (More info here [1])
>>
>> It produces mainly two kinds of outputs:
>>  * an account-like output, similar to the one given by Perf, example below.
>>  * a ring-char output, examples here [2].
>>
>> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log --account-file account.txt
>> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log -c account.txt
>>
>> This will produce an account file like this:
>>
>>     current bytes allocated:     669696
>>     current bytes requested:     618823
>>     current wasted bytes:         50873
>>     number of allocs:              7649
>>     number of frees:               2563
>>     number of callers:              115
>>
>>      total    waste      net alloc/free  caller
>>     ---------------------------------------------
>>     299200        0   298928  1100/1     alloc_inode+0x4fL
>>     189824        0   140544  1483/385   __d_alloc+0x22L
>>      51904        0    47552   811/68    sysfs_new_dirent+0x4eL
>>     [...]
>>
>> [1] http://elinux.org/Kernel_dynamic_memory_analysis
>> [2] http://elinux.org/Kernel_dynamic_memory_analysis#Current_dynamic_footprint
>>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Cc: Frederic Weisbecker <fweisbec@gmail.com>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
>
> Looks really useful! Dunno if this makes most sense as a separate
> script or as an extension perf.
>

I'm glad you think so.
Regarding the perf extension, I would have to think about that.
I guess you mean convert this script to use the python binding?

Will it still be able to work off-box? (a typical embedded scenario)

-- 
    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
