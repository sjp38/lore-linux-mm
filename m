Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7213B6B00B8
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 22:04:29 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so8443419pbb.1
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 19:04:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.186])
        by mx.google.com with SMTP id ul9si3971901pab.229.2013.11.05.19.04.26
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 19:04:27 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id hm4so3056565wib.12
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 19:04:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
 <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
 <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com> <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
From: Sameer Nanda <snanda@chromium.org>
Date: Tue, 5 Nov 2013 19:04:03 -0800
Message-ID: <CANMivWZrefY1bbgpJgABqcUwKfqOR9HQtGNY6cWdutcMASeo2A@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
Content-Type: multipart/alternative; boundary=f46d043c81de05431004ea79682b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luigi Semenzato <semenzato@google.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--f46d043c81de05431004ea79682b
Content-Type: text/plain; charset=UTF-8

On Tue, Nov 5, 2013 at 5:27 PM, David Rientjes <rientjes@google.com> wrote:

> On Tue, 5 Nov 2013, Luigi Semenzato wrote:
>
> > It's not enough to hold a reference to the task struct, because it can
> > still be taken out of the circular list of threads.  The RCU
> > assumptions don't hold in that case.
> >
>
> Could you please post a proper bug report that isolates this at the cause?
>

We've been running into this issue on Chrome OS. crbug.com/256326 has
additional
details.  The issue manifests itself as a soft lockup.

The kernel we've been seeing this on is 3.8.

We have a pretty consistent repro currently.  Happy to try out other
suggestions
for a fix.


>
> Thanks.
>



-- 
Sameer

--f46d043c81de05431004ea79682b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Tue, Nov 5, 2013 at 5:27 PM, David Rientjes <span dir=3D"ltr">&l=
t;<a href=3D"mailto:rientjes@google.com" target=3D"_blank">rientjes@google.=
com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex"><div class=3D"im">On Tue, 5 Nov 2013, Luigi Semenzato wrot=
e:<br>


<br>
&gt; It&#39;s not enough to hold a reference to the task struct, because it=
 can<br>
&gt; still be taken out of the circular list of threads. =C2=A0The RCU<br>
&gt; assumptions don&#39;t hold in that case.<br>
&gt;<br>
<br>
</div>Could you please post a proper bug report that isolates this at the c=
ause?<br></blockquote><div><br></div><div>We&#39;ve been running into this =
issue on Chrome OS. <a href=3D"http://crbug.com/256326">crbug.com/256326</a=
> has additional=C2=A0</div>

<div>details. =C2=A0The issue manifests itself as a soft lockup.<br></div><=
div><br></div><div>The kernel we&#39;ve been seeing this on is 3.8.</div><d=
iv><br></div><div>We have a pretty consistent repro currently. =C2=A0Happy =
to try out other suggestions</div>

<div>for a fix.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(=
204,204,204);border-left-style:solid;padding-left:1ex">
<br>
Thanks.<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>Sameer
</div></div>

--f46d043c81de05431004ea79682b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
