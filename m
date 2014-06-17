Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 468B16B0036
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:21:07 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so6590983vcb.2
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:21:06 -0700 (PDT)
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
        by mx.google.com with ESMTPS id j2si5668102vcy.78.2014.06.17.09.21.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:21:06 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id hy4so6652602vcb.34
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:21:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
 <CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com>
 <CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com>
 <CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>
 <CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com>
 <53A01049.6020502@redhat.com> <CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jun 2014 09:20:46 -0700
Message-ID: <CALCETrVpZ0vFM4usHK+tQhk234Y2jWzB1522kGcGvdQQFAqsZQ@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
Content-Type: multipart/alternative; boundary=089e01182c3ee1a3f004fc0a8717
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <greg@kroah.com>, Florian Weimer <fweimer@redhat.com>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Kay Sievers <kay@vrfy.org>, John Stultz <john.stultz@linaro.org>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel Mack <zonque@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Tony Battersby <tonyb@cybernetics.com>

--089e01182c3ee1a3f004fc0a8717
Content-Type: text/plain; charset=UTF-8

On Jun 17, 2014 3:01 AM, "David Herrmann" <dh.herrmann@gmail.com> wrote:
>
> Hi
>
> On Tue, Jun 17, 2014 at 11:54 AM, Florian Weimer <fweimer@redhat.com>
wrote:
> > On 06/13/2014 05:33 PM, David Herrmann wrote:
> >>
> >> On Fri, Jun 13, 2014 at 5:17 PM, Andy Lutomirski <luto@amacapital.net>
> >> wrote:
> >>>
> >>> Isn't the point of SEAL_SHRINK to allow servers to mmap and read
> >>> safely without worrying about SIGBUS?
> >>
> >>
> >> No, I don't think so.
> >> The point of SEAL_SHRINK is to prevent a file from shrinking. SIGBUS
> >> is an effect, not a cause. It's only a coincidence that "OOM during
> >> reads" and "reading beyond file-boundaries" has the same effect:
> >> SIGBUS.
> >> We only protect against reading beyond file-boundaries due to
> >> shrinking. Therefore, OOM-SIGBUS is unrelated to SEAL_SHRINK.
> >>
> >> Anyone dealing with mmap() _has_ to use mlock() to protect against
> >> OOM-SIGBUS. Making SEAL_SHRINK protect against OOM-SIGBUS would be
> >> redundant, because you can achieve the same with SEAL_SHRINK+mlock().
> >
> >
> > I don't think this is what potential users expect because mlock requires
> > capabilities which are not available to them.
> >
> > A couple of weeks ago, sealing was to be applied to anonymous shared
memory.
> > Has this changed?  Why should *reading* it trigger OOM?
>
> The file might have holes, therefore, you'd have to allocate backing
> pages. This might hit a soft-limit and fail. To avoid this, use
> fallocate() to allocate pages prior to mmap() or mlock() to make the
> kernel lock them in memory.
>

Can you summarize why holes can't be reliably backed by the zero page?

(I realize the kernel could OOM on PTE allocation, but fallocate won't fix
that. OTOH MAP_POPULATE should work.)

And I don't think I like hole filling being allowed on write-sealed files.
Holes are observable these days with SEEK_HOLE and such.

Alternatively, we could add a new syscall or madvise option to populate a
mapping.

--Andy

--089e01182c3ee1a3f004fc0a8717
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><p dir=3D"ltr"><br>
On Jun 17, 2014 3:01 AM, &quot;David Herrmann&quot; &lt;<a href=3D"mailto:d=
h.herrmann@gmail.com" target=3D"_blank">dh.herrmann@gmail.com</a>&gt; wrote=
:<br>
&gt;<br>
&gt; Hi<br>
&gt;<br>
&gt; On Tue, Jun 17, 2014 at 11:54 AM, Florian Weimer &lt;<a href=3D"mailto=
:fweimer@redhat.com" target=3D"_blank">fweimer@redhat.com</a>&gt; wrote:<br=
>
&gt; &gt; On 06/13/2014 05:33 PM, David Herrmann wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; On Fri, Jun 13, 2014 at 5:17 PM, Andy Lutomirski &lt;<a href=
=3D"mailto:luto@amacapital.net" target=3D"_blank">luto@amacapital.net</a>&g=
t;<br>
&gt; &gt;&gt; wrote:<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; Isn&#39;t the point of SEAL_SHRINK to allow servers to mm=
ap and read<br>
&gt; &gt;&gt;&gt; safely without worrying about SIGBUS?<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; No, I don&#39;t think so.<br>
&gt; &gt;&gt; The point of SEAL_SHRINK is to prevent a file from shrinking.=
 SIGBUS<br>
&gt; &gt;&gt; is an effect, not a cause. It&#39;s only a coincidence that &=
quot;OOM during<br>
&gt; &gt;&gt; reads&quot; and &quot;reading beyond file-boundaries&quot; ha=
s the same effect:<br>
&gt; &gt;&gt; SIGBUS.<br>
&gt; &gt;&gt; We only protect against reading beyond file-boundaries due to=
<br>
&gt; &gt;&gt; shrinking. Therefore, OOM-SIGBUS is unrelated to SEAL_SHRINK.=
<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Anyone dealing with mmap() _has_ to use mlock() to protect ag=
ainst<br>
&gt; &gt;&gt; OOM-SIGBUS. Making SEAL_SHRINK protect against OOM-SIGBUS wou=
ld be<br>
&gt; &gt;&gt; redundant, because you can achieve the same with SEAL_SHRINK+=
mlock().<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; I don&#39;t think this is what potential users expect because mlo=
ck requires<br>
&gt; &gt; capabilities which are not available to them.<br>
&gt; &gt;<br>
&gt; &gt; A couple of weeks ago, sealing was to be applied to anonymous sha=
red memory.<br>
&gt; &gt; Has this changed? =C2=A0Why should *reading* it trigger OOM?<br>
&gt;<br>
&gt; The file might have holes, therefore, you&#39;d have to allocate backi=
ng<br>
&gt; pages. This might hit a soft-limit and fail. To avoid this, use<br>
&gt; fallocate() to allocate pages prior to mmap() or mlock() to make the<b=
r>
&gt; kernel lock them in memory.<br>
&gt;</p>
<p dir=3D"ltr">Can you summarize why holes can&#39;t be reliably backed by =
the zero page?</p>
<p dir=3D"ltr">(I realize the kernel could OOM on PTE allocation, but fallo=
cate won&#39;t fix that. OTOH MAP_POPULATE should work.)</p>
<p dir=3D"ltr">And I don&#39;t think I like hole filling being allowed on w=
rite-sealed files.=C2=A0 Holes are observable these days with SEEK_HOLE and=
 such.</p><p>Alternatively, we could add a new syscall or madvise option to=
 populate a mapping.<br>

</p><p>--Andy</p></div>

--089e01182c3ee1a3f004fc0a8717--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
