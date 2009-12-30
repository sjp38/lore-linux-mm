Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F196060021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 08:03:28 -0500 (EST)
Received: by ywh5 with SMTP id 5so19334274ywh.11
        for <linux-mm@kvack.org>; Wed, 30 Dec 2009 05:03:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091228134245.8db992d1.nishimura@mxp.nes.nec.co.jp>
References: <cover.1261858972.git.kirill@shutemov.name>
	 <3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	 <59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	 <c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	 <7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
	 <20091228134245.8db992d1.nishimura@mxp.nes.nec.co.jp>
Date: Wed, 30 Dec 2009 15:03:25 +0200
Message-ID: <cc557aab0912300503o68035872uedab7f840205b7a3@mail.gmail.com>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 28, 2009 at 6:42 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> It would be a nitpick, but my patch(http://marc.info/?l=3Dlinux-mm-commit=
s&m=3D126152804420992&w=3D2)
> has already modified here.
>
> I think it might be better for you to apply my patches by hand or wait fo=
r next mmotm
> to be released to avoid bothering Andrew.
> (There is enough time left till the next merge window :))

I'll rebase it later.

> (snip)
>
>> +static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *thresholds;
>> + =C2=A0 =C2=A0 u64 usage =3D mem_cgroup_usage(memcg, swap);
>> + =C2=A0 =C2=A0 int i, cur;
>> +
> I think calling mem_cgroup_usage() after checking "if(!thresholds)"
> decreases the overhead a little when we don't set any thresholds.
> I've confirmed that the change makes the assembler output different.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
