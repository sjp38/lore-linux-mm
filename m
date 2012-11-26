Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A2DE86B006C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:59:37 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hj6so2877048wib.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 10:59:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121126164555.GL31891@thunk.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
	<20121126163328.ACEB011FE9C@bugzilla.kernel.org>
	<20121126164555.GL31891@thunk.org>
Date: Tue, 27 Nov 2012 00:29:35 +0530
Message-ID: <CANPs=i4xSJPD6+Y0UCk7rOY6qFpnpnF4h4FT+bN5K3tGGA3x_g@mail.gmail.com>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page range
From: Hiro Lalwani <meetmehiro@gmail.com>
Content-Type: multipart/alternative; boundary=001636ef0283d38c4104cf6a88f3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--001636ef0283d38c4104cf6a88f3
Content-Type: text/plain; charset=ISO-8859-1

 Thanks a lot Theodore Ts'o ...

 Thanks to all (kernel,ext4 ..etc. )developer for quick debug and
response...


On Mon, Nov 26, 2012 at 10:15 PM, Theodore Ts'o <tytso@mit.edu> wrote:

> On Mon, Nov 26, 2012 at 04:33:28PM +0000,
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=50981
> >
> > as this is working properly with XFS, so in ext4/ext3...etc also we
> shouldn't
> > require synchronization at the Application level,., FS should take care
> of
> > locking... will we expecting the fix for the same ???
>
> Meetmehiro,
>
> At this point, there seems to be consensus that the kernel should take
> care of the locking, and that this is not something that needs be a
> worry for the application.  Whether this should be done in the file
> system layer or in the mm layer is the current question at hand ---
> since this is a bug that also affects btrfs and other non-XFS file
> systems.
>
> So the question is whether every file system which supports AIO should
> add its own locking, or whether it should be done at the mm layer, and
> at which point the lock in the XFS layer could be removed as no longer
> necessary.
>
> I've added linux-mm and linux-fsdevel to make sure all of the relevant
> kernel developers are aware of this question/issue.
>
> Regards,
>
>                                                 - Ted
>



-- 
thanks & regards
Hiro Lalwani

--001636ef0283d38c4104cf6a88f3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

=A0Thanks a lot Theodore Ts&#39;o ...<div><br></div><div>=A0Thanks to all (=
kernel,ext4 ..etc. )developer for quick debug and response...</div><div><br=
></div><div><br><div class=3D"gmail_quote">On Mon, Nov 26, 2012 at 10:15 PM=
, Theodore Ts&#39;o <span dir=3D"ltr">&lt;<a href=3D"mailto:tytso@mit.edu" =
target=3D"_blank">tytso@mit.edu</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">On Mon, Nov 26, 2012 at 04:33:28PM +0000, <a=
 href=3D"mailto:bugzilla-daemon@bugzilla.kernel.org">bugzilla-daemon@bugzil=
la.kernel.org</a> wrote:<br>

&gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D50981" target=
=3D"_blank">https://bugzilla.kernel.org/show_bug.cgi?id=3D50981</a><br>
&gt;<br>
&gt; as this is working properly with XFS, so in ext4/ext3...etc also we sh=
ouldn&#39;t<br>
&gt; require synchronization at the Application level,., FS should take car=
e of<br>
&gt; locking... will we expecting the fix for the same ???<br>
<br>
Meetmehiro,<br>
<br>
At this point, there seems to be consensus that the kernel should take<br>
care of the locking, and that this is not something that needs be a<br>
worry for the application. =A0Whether this should be done in the file<br>
system layer or in the mm layer is the current question at hand ---<br>
since this is a bug that also affects btrfs and other non-XFS file<br>
systems.<br>
<br>
So the question is whether every file system which supports AIO should<br>
add its own locking, or whether it should be done at the mm layer, and<br>
at which point the lock in the XFS layer could be removed as no longer<br>
necessary.<br>
<br>
I&#39;ve added linux-mm and linux-fsdevel to make sure all of the relevant<=
br>
kernel developers are aware of this question/issue.<br>
<br>
Regards,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 - Ted<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>thanks &amp;=
 regards<br>Hiro Lalwani<br>
</div>

--001636ef0283d38c4104cf6a88f3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
