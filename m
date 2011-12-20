Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 984636B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 19:30:48 -0500 (EST)
Received: by eabm6 with SMTP id m6so5175035eab.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 16:30:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EEF6240.9020107@gmail.com>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
	<4EEF6240.9020107@gmail.com>
Date: Tue, 20 Dec 2011 09:30:46 +0900
Message-ID: <CABEgKgrnTN6YbtPbuifyEvgUi7MB47VriVhn8EAAds1k2O83XA@mail.gmail.com>
Subject: Re: Android low memory killer vs. memory pressure notifications
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2011/12/20 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
>> - Use memory controller cgroup (CGROUP_MEM_RES_CTLR) notifications from
>> =A0 the kernel side, plus userland "manager" that would kill application=
s.
>>
>> =A0 The main downside of this approach is that mem_cg needs 20 bytes per
>> =A0 page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>> =A0 that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine=
.
>>
>> =A0 0.5% doesn't sound too bad, but 5MB does, quite a little bit. So,
>> =A0 mem_cg feels like an overkill for this simple task (see the driver a=
t
>> =A0 the very bottom).
>
>
> Kamezawa-san, Is 20bytes/page still correct now? If I remember correctly,
> you improved space efficiency of memcg.
>
Johannes removed 4 bytes. It's in upstream.
Johannes removed 8bytes. It's now in linux-next.
I'm preparing a patch to remove more 4 bytes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
