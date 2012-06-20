Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 44E826B0081
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:03:04 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so6808045wgb.26
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 04:03:02 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
Date: Wed, 20 Jun 2012 07:03:02 -0400
Message-ID: <CAPbh3rtA3AcR3TU2-dGpgLOR-TfkXcGAmZJASDwAdsEi_GfK-w@mail.gmail.com>
Subject: Re: help converting zcache from sysfs to debugfs?
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: multipart/alternative; boundary=f46d04428d2abb3e0a04c2e5575f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>

--f46d04428d2abb3e0a04c2e5575f
Content-Type: text/plain; charset=ISO-8859-1

On Jun 19, 2012 8:30 PM, "Dan Magenheimer" <dan.magenheimer@oracle.com>
wrote:
>
> Zcache (in staging) has a large number of read-only counters that
> are primarily of interest to developers.  These counters are currently
> visible from sysfs.  However sysfs is not really appropriate and
> zcache will need to switch to debugfs before it can be promoted
> out of staging.
>
> For some of the counters, it is critical that they remain accurate so
> an atomic_t must be used.  But AFAICT there is no way for debugfs
> to work with atomic_t.

Which ones must be atomic? Do they really need to be atomic if they are for
diagnostics/developers?
>
> Is that correct?  Or am I missing something?
>
> Assuming it is correct, I have a workaround but it is ugly:
>
> static unsigned long counterX;
> static atomic_t atomic_counterX;
>
>        counterX = atomic_*_return(atomic_counterX)
>
> and use atomic_counter in normal code and counter for debugfs.
>
> This works but requires each counter to be stored twice AND
> makes the code look ugly.

But only for those counters that truly must be atomic.
>
> Is there a better way?  I can probably bury the ugliness in
> macros but that doesn't solve the duplicate storage.  (Though
> since there are only about a dozen, maybe it doesn't matter?)

A dozen that _MUST_ be atomic?

>
> Thanks,
> Dan
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href
>

--f46d04428d2abb3e0a04c2e5575f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Jun 19, 2012 8:30 PM, &quot;Dan Magenheimer&quot; &lt;<a href=3D"mailto:=
dan.magenheimer@oracle.com" target=3D"_blank">dan.magenheimer@oracle.com</a=
>&gt; wrote:<br>
&gt;<br>
&gt; Zcache (in staging) has a large number of read-only counters that<br>
&gt; are primarily of interest to developers. =A0These counters are current=
ly<br>
&gt; visible from sysfs. =A0However sysfs is not really appropriate and<br>
&gt; zcache will need to switch to debugfs before it can be promoted<br>
&gt; out of staging.<br>
&gt;<br>
&gt; For some of the counters, it is critical that they remain accurate so<=
br>
&gt; an atomic_t must be used. =A0But AFAICT there is no way for debugfs<br=
>
&gt; to work with atomic_t.</p>
<p>Which ones must be atomic? Do they really need to be atomic if they are =
for diagnostics/developers?<br>
&gt;<br>
&gt; Is that correct? =A0Or am I missing something?<br>
&gt;<br>
&gt; Assuming it is correct, I have a workaround but it is ugly:<br>
&gt;<br>
&gt; static unsigned long counterX;<br>
&gt; static atomic_t atomic_counterX;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0counterX =3D atomic_*_return(atomic_counterX)<br>
&gt;<br>
&gt; and use atomic_counter in normal code and counter for debugfs.<br>
&gt;<br>
&gt; This works but requires each counter to be stored twice AND<br>
&gt; makes the code look ugly.</p>
<p>But only for those counters that truly must be atomic. <br>
&gt;<br>
&gt; Is there a better way? =A0I can probably bury the ugliness in<br>
&gt; macros but that doesn&#39;t solve the duplicate storage. =A0(Though<br=
>
&gt; since there are only about a dozen, maybe it doesn&#39;t matter?)</p><=
p>A dozen that _MUST_ be atomic?</p><p>
&gt;<br>
&gt; Thanks,<br>
&gt; Dan<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org" target=3D"_blank">m=
ajordomo@kvack.org</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Don&#39;t email: &lt;a href<br>
&gt;<br>
</p>

--f46d04428d2abb3e0a04c2e5575f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
