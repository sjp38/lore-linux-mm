Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E46B36B0133
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:05:25 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4385669ggm.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 23:05:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE92AF9.4050309@jp.fujitsu.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206251846450.24838@chino.kir.corp.google.com> <4FE92AF9.4050309@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 02:05:04 -0400
Message-ID: <CAHGf_=pOvakOtZA9fWRGchgSb8k80O0Y8D-yUrmFWuoQOqkePQ@mail.gmail.com>
Subject: Re: [rfc][patch 2/3] mm, oom: introduce helper function to process
 threads during scan
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Jun 25, 2012 at 11:22 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/06/26 10:47), David Rientjes wrote:
>>
>> This patch introduces a helper function to process each thread during th=
e
>> iteration over the tasklist. =A0A new return type, enum oom_scan_t, is
>> defined to determine the future behavior of the iteration:
>>
>> =A0- OOM_SCAN_OK: continue scanning the thread and find its badness,
>>
>> =A0- OOM_SCAN_CONTINUE: do not consider this thread for oom kill, it's
>> =A0 =A0ineligible,
>>
>> =A0- OOM_SCAN_ABORT: abort the iteration and return, or
>>
>> =A0- OOM_SCAN_SELECT: always select this thread with the highest badness
>> =A0 =A0possible.
>>
>> There is no functional change with this patch. =A0This new helper functi=
on
>> will be used in the next patch in the memory controller.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>
>
> I like this.
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
