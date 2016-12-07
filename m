Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 000A16B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:39:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so99319111pgc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:39:39 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30050.outbound.protection.outlook.com. [40.107.3.50])
        by mx.google.com with ESMTPS id f67si24584856pfk.78.2016.12.07.07.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 07:39:39 -0800 (PST)
Received: by mail-wj0-f180.google.com with SMTP id tk12so69620366wjb.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:39:36 -0800 (PST)
MIME-Version: 1.0
From: Federico Reghenzani <federico.reghenzani@polimi.it>
Date: Wed, 7 Dec 2016 16:39:13 +0100
Message-ID: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
Subject: mlockall() with pid parameter
Content-Type: multipart/alternative; boundary="047d7b5d8671d58959054313537c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--047d7b5d8671d58959054313537c
Content-Type: text/plain; charset="UTF-8"

Hello,

I'm working on Real-Time applications in Linux. `mlockall()` is a typical
syscall used in RT processes in order to avoid page faults. However, the
use of this syscall is strongly limited by ulimits, so basically all RT
processes that want to call `mlockall()` have to be executed with root
privileges.

What I would like to have is a syscall that accept a "pid", so a process
spawned by root would be able to enforce the memory locking to other
non-root processes. The prototypes would be:

int mlockall(int flags, pid_t pid);
int munlockall(pid_t pid);

I checked the source code and it seems to me quite easy to add this syscall
variant.

I'm writing here to have a feedback before starting to edit the code. Do
you think that this is a good approach?


Thank you,
Federico

-- 
*Federico Reghenzani*
PhD Candidate
Politecnico di Milano
Dipartimento di Elettronica, Informazione e Bioingegneria

--047d7b5d8671d58959054313537c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<div><br></div><div>I&#39;m working on Real-Time app=
lications in Linux. `mlockall()` is a typical syscall used in RT processes =
in order to avoid page faults. However, the use of this syscall is strongly=
 limited by ulimits, so basically all RT processes that want to call `mlock=
all()` have to be executed with root privileges.</div><div><br></div><div>W=
hat I would like to have is a syscall that accept a &quot;pid&quot;, so a p=
rocess spawned by root would be able to enforce the memory locking to other=
 non-root processes. The prototypes would be:</div><div><br></div><div>int =
mlockall(int flags, pid_t pid);<br></div><div>int munlockall(pid_t pid);<br=
></div><div><br></div><div>I checked the source code and it seems to me qui=
te easy to add this syscall variant.</div><div><br></div><div>I&#39;m writi=
ng here to have a feedback before starting to edit the code. Do you think t=
hat this is a good approach?</div><div><br></div><div><br></div><div>Thank =
you,</div><div>Federico<br clear=3D"all"><div><br></div>-- <br><div class=
=3D"gmail_signature"><div dir=3D"ltr"><b>Federico Reghenzani</b><div><font =
size=3D"1">PhD Candidate</font></div><div><font size=3D"1">Politecnico di M=
ilano</font></div><div><font size=3D"1">Dipartimento di Elettronica, Inform=
azione e Bioingegneria</font></div><div><br></div></div></div>
</div></div>

--047d7b5d8671d58959054313537c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
