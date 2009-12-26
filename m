Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8629760021B
	for <linux-mm@kvack.org>; Sat, 26 Dec 2009 18:37:51 -0500 (EST)
Received: by ywh5 with SMTP id 5so12396655ywh.11
        for <linux-mm@kvack.org>; Sat, 26 Dec 2009 15:37:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091226133011.GA10944@balbir.in.ibm.com>
References: <cover.1261786326.git.kirill@shutemov.name>
	 <20091226133011.GA10944@balbir.in.ibm.com>
Date: Sun, 27 Dec 2009 01:37:28 +0200
Message-ID: <cc557aab0912261537n2f2e798u4338b4d1f31067e6@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] cgroup notifications API and memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 26, 2009 at 3:30 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Kirill A. Shutemov <kirill@shutemov.name> [2009-12-26 02:30:56]:
>
>> This patchset introduces eventfd-based API for notifications in cgroups =
and
>> implements memory notifications on top of it.
>>
>> It uses statistics in memory controler to track memory usage.
>>
>> Output of time(1) on building kernel on tmpfs:
>>
>> Root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.37 user 60.93s system 193% cpu 4=
:52.77 total
>> Non-root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.14 user 62.66s system 193% cpu 4=
:54.74 total
>> Root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.13 user 62.20s system 193% cpu 4=
:53.55 total
>> Non-root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.70 user 64.20s system 193% cpu 4=
:55.70 total
>> Root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.97 user 62.20s system 193% cpu 4=
:53.90 total
>> Non-root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.55 user 64.08s system 193% cpu 4=
:55.63 total
>>
>> Any comments?
>
> Could you please add some documentation for end users.

Sure. I'll send new version of patchset with documentation soon.

> I've just
> compiled a kernel with your changes for test. Also, is there a reason
> not to use cgroupstats?

I'm not sure that understand you correctly. Could you explain the idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
