Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA2406B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:22:53 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p4CHMnmd010999
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:22:49 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by hpaq13.eem.corp.google.com with ESMTP id p4CHKBMP015341
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:22:48 -0700
Received: by qyk32 with SMTP id 32so3404441qyk.8
        for <linux-mm@kvack.org>; Thu, 12 May 2011 10:22:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DCBF67A.3060700@redhat.com>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
	<4DCBF67A.3060700@redhat.com>
Date: Thu, 12 May 2011 10:22:47 -0700
Message-ID: <BANLkTinJB0=bcVH9vvNz6_ONy17nBAJbQg@mail.gmail.com>
Subject: Re: [rfc patch 1/6] memcg: remove unused retry signal from reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc1c6ee104a3177015
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--000e0ce008bc1c6ee104a3177015
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 8:02 AM, Rik van Riel <riel@redhat.com> wrote:

> On 05/12/2011 10:53 AM, Johannes Weiner wrote:
>
>> If the memcg reclaim code detects the target memcg below its limit it
>> exits and returns a guaranteed non-zero value so that the charge is
>> retried.
>>
>> Nowadays, the charge side checks the memcg limit itself and does not
>> rely on this non-zero return value trick.
>>
>> This patch removes it.  The reclaim code will now always return the
>> true number of pages it reclaimed on its own.
>>
>> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
>>
>
> Acked-by: Rik van Riel<riel@redhat.com>
>

Acked-by: Ying Han<yinghan@google.com>

--000e0ce008bc1c6ee104a3177015
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 8:02 AM, Rik van=
 Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com">riel@redhat.=
com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On 05/12/2011 10:53 AM, Johannes Weiner wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
If the memcg reclaim code detects the target memcg below its limit it<br>
exits and returns a guaranteed non-zero value so that the charge is<br>
retried.<br>
<br>
Nowadays, the charge side checks the memcg limit itself and does not<br>
rely on this non-zero return value trick.<br>
<br>
This patch removes it. =A0The reclaim code will now always return the<br>
true number of pages it reclaimed on its own.<br>
<br>
Signed-off-by: Johannes Weiner&lt;<a href=3D"mailto:hannes@cmpxchg.org" tar=
get=3D"_blank">hannes@cmpxchg.org</a>&gt;<br>
</blockquote>
<br></div>
Acked-by: Rik van Riel&lt;<a href=3D"mailto:riel@redhat.com" target=3D"_bla=
nk">riel@redhat.com</a>&gt;<br></blockquote><div><br></div><meta http-equiv=
=3D"content-type" content=3D"text/html; charset=3Dutf-8"><div>Acked-by: Yin=
g Han&lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt;=
=A0</div>
</div><br>

--000e0ce008bc1c6ee104a3177015--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
