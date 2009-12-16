Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3D36B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 21:14:31 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id nBG2EQfl020664
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 02:14:26 GMT
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by spaceape9.eur.corp.google.com with ESMTP id nBG2ENGG024793
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:23 -0800
Received: by pzk1 with SMTP id 1so348140pzk.33
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091214151943.3893112f.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
	 <20091214151943.3893112f.nishimura@mxp.nes.nec.co.jp>
Date: Tue, 15 Dec 2009 18:14:22 -0800
Message-ID: <6599ad830912151814i1ef48cexf86ae95bca2955ff@mail.gmail.com>
Subject: Re: [PATCH -mmotm 2/8] cgroup: introduce coalesce css_get() and
	css_put()
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 13, 2009 at 10:19 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> Current css_get() and css_put() increment/decrement css->refcnt one by on=
e.
>
> This patch add a new function __css_get(), which takes "count" as a arg a=
nd
> increment the css->refcnt by "count". And this patch also add a new arg("=
count")
> to __css_put() and change the function to decrement the css->refcnt by "c=
ount".
>
> These coalesce version of __css_get()/__css_put() will be used to improve
> performance of memcg's moving charge feature later, where instead of call=
ing
> css_get()/css_put() repeatedly, these new functions will be used.
>
> No change is needed for current users of css_get()/css_put().
>
> Changelog: 2009/12/14
> - new patch(I split "[4/7] memcg: improbe performance in moving charge" o=
f
> =A004/Dec version into 2 part: cgroup part and memcg part. This is the cg=
roup
> =A0part.)
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: Paul Menage <menage@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
