Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B24746B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:03:58 -0500 (EST)
Received: by obbta7 with SMTP id ta7so2303732obb.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 10:03:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F467579.3020509@jp.fujitsu.com>
References: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
	<4F467579.3020509@jp.fujitsu.com>
Date: Thu, 23 Feb 2012 20:03:57 +0200
Message-ID: <CAOJsxLH+2qbshWX3ufFve__ZLu4KAqcaF+3QEkOaGrGaAFbk2w@mail.gmail.com>
Subject: Re: [patch] mm, oom: force oom kill on sysrq+f
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Thu, Feb 23, 2012 at 7:20 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> On 2/22/2012 7:03 PM, David Rientjes wrote:
>> The oom killer chooses not to kill a thread if:
>>
>> =A0- an eligible thread has already been oom killed and has yet to exit,
>> =A0 =A0and
>>
>> =A0- an eligible thread is exiting but has yet to free all its memory an=
d
>> =A0 =A0is not the thread attempting to currently allocate memory.
>>
>> SysRq+F manually invokes the global oom killer to kill a memory-hogging
>> task. =A0This is normally done as a last resort to free memory when no
>> progress is being made or to test the oom killer itself.
>>
>> For both uses, we always want to kill a thread and never defer. =A0This
>> patch causes SysRq+F to always kill an eligible thread and can be used t=
o
>> force a kill even if another oom killed thread has failed to exit.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>
> I have similar patch. This is very sane idea.
> =A0 =A0 =A0 =A0Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
