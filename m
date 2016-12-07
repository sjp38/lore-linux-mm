Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92E456B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:33:46 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u15so671497726oie.6
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:33:46 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0056.outbound.protection.outlook.com. [104.47.2.56])
        by mx.google.com with ESMTPS id z22si12211285oia.136.2016.12.07.08.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 08:33:45 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id f82so175459576wmf.1
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:33:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz>
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
 <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz>
From: Federico Reghenzani <federico.reghenzani@polimi.it>
Date: Wed, 7 Dec 2016 17:33:19 +0100
Message-ID: <CACKey4yB_qXdRn1=qNu65GA0ER-DL+DEqhP9QRGkWX79jVao8g@mail.gmail.com>
Subject: Re: mlockall() with pid parameter
Content-Type: multipart/alternative; boundary="001a114d46b85c4168054314158e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Federico Reghenzani <federico.reghenzani@polimi.it>, linux-mm@kvack.org

--001a114d46b85c4168054314158e
Content-Type: text/plain; charset="UTF-8"

2016-12-07 17:21 GMT+01:00 Vlastimil Babka <vbabka@suse.cz>:

> On 12/07/2016 04:39 PM, Federico Reghenzani wrote:
> > Hello,
> >
> > I'm working on Real-Time applications in Linux. `mlockall()` is a
> > typical syscall used in RT processes in order to avoid page faults.
> > However, the use of this syscall is strongly limited by ulimits, so
> > basically all RT processes that want to call `mlockall()` have to be
> > executed with root privileges.
>
> Is it not possible to change the ulimits with e.g. prlimit?
>
>
Yes, but it requires a synchronization between non-root process and root
process.
Because the root process has to change the limits before the non-root
process executes the mlockall().

Just to provide an example, another syscall used in RT tasks is the
sched_setscheduler() that also suffers
the limitation of ulimits, but it accepts the pid so the scheduling policy
can be enforced by a root process to
any other process.



> > What I would like to have is a syscall that accept a "pid", so a process
> > spawned by root would be able to enforce the memory locking to other
> > non-root processes. The prototypes would be:
> >
> > int mlockall(int flags, pid_t pid);
> > int munlockall(pid_t pid);
> >
> > I checked the source code and it seems to me quite easy to add this
> > syscall variant.
> >
> > I'm writing here to have a feedback before starting to edit the code. Do
> > you think that this is a good approach?
> >
> >
> > Thank you,
> > Federico
> >
> > --
> > *Federico Reghenzani*
> > PhD Candidate
> > Politecnico di Milano
> > Dipartimento di Elettronica, Informazione e Bioingegneria
> >
>
>


-- 
*Federico Reghenzani*
PhD Candidate
Politecnico di Milano
Dipartimento di Elettronica, Informazione e Bioingegneria

--001a114d46b85c4168054314158e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2016-12-07 17:21 GMT+01:00 Vlastimil Babka <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;</span>=
:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=3D"gmail=
-">On 12/07/2016 04:39 PM, Federico Reghenzani wrote:<br>
&gt; Hello,<br>
&gt;<br>
&gt; I&#39;m working on Real-Time applications in Linux. `mlockall()` is a<=
br>
&gt; typical syscall used in RT processes in order to avoid page faults.<br=
>
&gt; However, the use of this syscall is strongly limited by ulimits, so<br=
>
&gt; basically all RT processes that want to call `mlockall()` have to be<b=
r>
&gt; executed with root privileges.<br>
<br>
</span>Is it not possible to change the ulimits with e.g. prlimit?<br>
<span class=3D"gmail-"><br></span></blockquote><div><br></div><div>Yes, but=
 it requires a synchronization between non-root process and root process.</=
div><div>Because the root process has to change the limits before the non-r=
oot process executes the mlockall().</div><div><br></div><div>Just to provi=
de an example, another syscall used in RT tasks is the sched_setscheduler()=
 that also suffers</div><div>the limitation of ulimits, but it accepts the =
pid so the scheduling policy can be enforced by a root process to</div><div=
>any other process.</div><div>=C2=A0</div><div>=C2=A0</div><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid r=
gb(204,204,204);padding-left:1ex"><span class=3D"gmail-">
&gt; What I would like to have is a syscall that accept a &quot;pid&quot;, =
so a process<br>
&gt; spawned by root would be able to enforce the memory locking to other<b=
r>
&gt; non-root processes. The prototypes would be:<br>
&gt;<br>
&gt; int mlockall(int flags, pid_t pid);<br>
&gt; int munlockall(pid_t pid);<br>
&gt;<br>
&gt; I checked the source code and it seems to me quite easy to add this<br=
>
&gt; syscall variant.<br>
&gt;<br>
&gt; I&#39;m writing here to have a feedback before starting to edit the co=
de. Do<br>
&gt; you think that this is a good approach?<br>
&gt;<br>
&gt;<br>
&gt; Thank you,<br>
&gt; Federico<br>
&gt;<br>
&gt; --<br>
</span>&gt; *Federico Reghenzani*<br>
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5">&gt; PhD Candidate<br>
&gt; Politecnico di Milano<br>
&gt; Dipartimento di Elettronica, Informazione e Bioingegneria<br>
&gt;<br>
<br>
</div></div></blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>=
<div class=3D"gmail_signature"><div dir=3D"ltr"><b>Federico Reghenzani</b><=
div><font size=3D"1">PhD Candidate</font></div><div><font size=3D"1">Polite=
cnico di Milano</font></div><div><font size=3D"1">Dipartimento di Elettroni=
ca, Informazione e Bioingegneria</font></div><div><br></div></div></div>
</div></div>

--001a114d46b85c4168054314158e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
