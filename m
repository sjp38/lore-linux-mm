Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 890616B0098
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 08:05:38 -0400 (EDT)
Received: by iwn34 with SMTP id 34so983470iwn.12
        for <linux-mm@kvack.org>; Sat, 03 Oct 2009 05:05:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6599ad830910021501s66cfc108r9a109b84b0f658a4@mail.gmail.com>
References: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
	 <20091002173955.5F72.A69D9226@jp.fujitsu.com>
	 <6599ad830910021501s66cfc108r9a109b84b0f658a4@mail.gmail.com>
Date: Sat, 3 Oct 2009 21:05:44 +0900
Message-ID: <2f11576a0910030505w5a1289ebu78cdc3587caddc82@mail.gmail.com>
Subject: Re: [PATCH 3/3] cgroup: fix strstrip() abuse
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>> cgroup_write_X64() and cgroup_write_string() ignore the return
>> value of strstrip().
>> it makes small inconsistent behavior.
>>
>> example:
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>> =A0# cd /mnt/cgroup/hoge
>> =A0# cat memory.swappiness
>> =A060
>> =A0# echo "59 " > memory.swappiness
>> =A0# cat memory.swappiness
>> =A059
>> =A0# echo " 58" > memory.swappiness
>> =A0bash: echo: write error: Invalid argument
>>
>>
>> This patch fixes it.
>>
>> Cc: Li Zefan <lizf@cn.fujitsu.com>
>> Cc: Paul Menage <menage@google.com>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Acked-by: Paul Menage <menage@google.com>
>
> Thanks - although I think I'd s/abuse/misuse/ in the description.

I don't know what's different between them. My dictionary is slightly quiet=
 ;)
Is this X-rated word? if so, I'll resend it soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
