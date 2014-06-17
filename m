Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7A42B6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:22:04 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id sa20so5916848veb.38
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:22:04 -0700 (PDT)
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
        by mx.google.com with ESMTPS id r4si1064129vdp.12.2014.06.17.09.22.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:22:03 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so6478328vcb.25
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:22:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53A00EDB.3050108@redhat.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net>
 <20140410203246.GB31614@thunk.org> <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
 <53A00EDB.3050108@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jun 2014 09:21:43 -0700
Message-ID: <CALCETrXsY9zqD5parMwmRBw5wEOQDstXGQ8zs_UQHYMyueJwaw@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Content-Type: multipart/alternative; boundary=001a11c1f8044dd47d04fc0a8b5a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Greg KH <greg@kroah.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Alexander Viro <viro@zeniv.linux.org.uk>, John Stultz <john.stultz@linaro.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Ryan Lortie <desrt@desrt.ca>, Daniel Mack <zonque@gmail.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-kernel <linux-kernel@vger.kernel.org>, David Herrmann <dh.herrmann@gmail.com>, Karol Lewandowski <k.lewandowsk@samsung.com>

--001a11c1f8044dd47d04fc0a8b5a
Content-Type: text/plain; charset=UTF-8

On Jun 17, 2014 2:48 AM, "Florian Weimer" <fweimer@redhat.com> wrote:
>
> On 04/10/2014 10:37 PM, Andy Lutomirski wrote:
>
>> It occurs to me that, before going nuts with these kinds of flags, it
>> may pay to just try to fix the /proc/self/fd issue for real -- we
>> could just make open("/proc/self/fd/3", O_RDWR) fail if fd 3 is
>> read-only.  That may be enough for the file sealing thing.
>
>
> Increasing privilege on O_PATH descriptors via access through
/proc/self/fd is part of the userspace API.  The same thing might be true
for O_RDONLY descriptors, but it's a bit less likely that there are any
users out there.  In any case, I'm not sure it makes sense to plug the
O_RDONLY hole while leaving the O_PATH hole open.

Do you mean O_PATH fds for the directory or O_PATH fds for the file
itself?  In any event, I'm much less concerned about passing O_PATH memfds
around than O_RDONLY memfds.

I have incomplete patches for this stuff.  I need to fix them so they work
and get past Al Viro.


--Andy

--001a11c1f8044dd47d04fc0a8b5a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><p dir=3D"ltr"><br>
On Jun 17, 2014 2:48 AM, &quot;Florian Weimer&quot; &lt;<a href=3D"mailto:f=
weimer@redhat.com" target=3D"_blank">fweimer@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On 04/10/2014 10:37 PM, Andy Lutomirski wrote:<br>
&gt;<br>
&gt;&gt; It occurs to me that, before going nuts with these kinds of flags,=
 it<br>
&gt;&gt; may pay to just try to fix the /proc/self/fd issue for real -- we<=
br>
&gt;&gt; could just make open(&quot;/proc/self/fd/3&quot;, O_RDWR) fail if =
fd 3 is<br>
&gt;&gt; read-only. =C2=A0That may be enough for the file sealing thing.<br=
>
&gt;<br>
&gt;<br>
&gt; Increasing privilege on O_PATH descriptors via access through /proc/se=
lf/fd is part of the userspace API. =C2=A0The same thing might be true for =
O_RDONLY descriptors, but it&#39;s a bit less likely that there are any use=
rs out there. =C2=A0In any case, I&#39;m not sure it makes sense to plug th=
e O_RDONLY hole while leaving the O_PATH hole open.</p>



<p dir=3D"ltr">Do you mean O_PATH fds for the directory or O_PATH fds for t=
he file itself?=C2=A0 In any event, I&#39;m much less concerned about passi=
ng O_PATH memfds around than O_RDONLY memfds.<br></p>
<p dir=3D"ltr">I have incomplete patches for this stuff.=C2=A0 I need to fi=
x them so they work and get past Al Viro.</p><p dir=3D"ltr"><br></p><p>--An=
dy</p></div>

--001a11c1f8044dd47d04fc0a8b5a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
