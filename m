Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9602F6B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 05:00:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k186so98473143qkb.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 02:00:41 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id 129si4127004vkn.235.2016.09.02.02.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 02:00:40 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id j189so8074623vkc.2
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 02:00:40 -0700 (PDT)
MIME-Version: 1.0
From: Anand Kumar <anand.kumar@goibibo.com>
Date: Fri, 2 Sep 2016 14:30:39 +0530
Message-ID: <CAMobVyy7Lm++6OAjj8HAdGSLzSMsNneEN_nqL8Nfrg4miRv27g@mail.gmail.com>
Subject: 
Content-Type: multipart/alternative; boundary=001a11440b328817f2053b829032
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11440b328817f2053b829032
Content-Type: text/plain; charset=UTF-8

Hi,
  I am trying to start cassandra service, and its start after 2-3 min its
automatically killed, will you please help me on this.


this is log what i get
-----------------------------
Sep  2 14:14:11 nmlgosocialcass02 kernel: TCP: TCP: Possible SYN flooding
on port 9042. Sending cookies.  Check SNMP counters.
Sep  2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] Unhandled sense
code
Sep  2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:16:57 nmlgosocialcass02 kernel: Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
Sep  2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:16:57 nmlgosocialcass02 kernel: Sense Key : Medium Error
[current]
Sep  2 14:16:57 nmlgosocialcass02 kernel: Info fld=0x141fc62c
Sep  2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:16:57 nmlgosocialcass02 kernel: Add. Sense: Unrecovered read error
Sep  2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] CDB:
Sep  2 14:16:57 nmlgosocialcass02 kernel: Read(10): 28 00 28 3f 8c a8 00 00
80 00
Sep  2 14:16:57 nmlgosocialcass02 kernel: end_request: critical target
error, dev sda, sector 675253416
Sep  2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] Unhandled sense
code
Sep  2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:17:00 nmlgosocialcass02 kernel: Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
Sep  2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:17:00 nmlgosocialcass02 kernel: Sense Key : Medium Error
[current]
Sep  2 14:17:00 nmlgosocialcass02 kernel: Info fld=0x141fc62c
Sep  2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]
Sep  2 14:17:00 nmlgosocialcass02 kernel: Add. Sense: Unrecovered read error
Sep  2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] CDB:
Sep  2 14:17:00 nmlgosocialcass02 kernel: Read(10): 28 00 28 3f 8c a8 00 00
08 00
Sep  2 14:17:00 nmlgosocialcass02 kernel: end_request: critical target
error, dev sda, sector 675253416
Sep  2 14:17:23 nmlgosocialcass02 abrt[1957]: Saved core dump of pid 1330
(/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.91-3.b14.el6_8.x86_64/jre/bin/java)
to /var/spool/abrt/ccpp-2016-09-02-14:17:00-1330 (9570549760 bytes)
Sep  2 14:17:23 nmlgosocialcass02 abrt[1957]: /var/spool/abrt is
19120585808 bytes (more than 1535MiB), deleting
'ccpp-2016-08-29-16:36:28-13346'
Sep  2 14:17:23 nmlgosocialcass02 abrtd: Directory
'ccpp-2016-09-02-14:17:00-1330' creation detected
Sep  2 14:17:29 nmlgosocialcass02 kernel: nr_pdflush_threads exported in
/proc is scheduled for removal
Sep  2 14:17:29 nmlgosocialcass02 kernel: sysctl: The
scan_unevictable_pages sysctl/node-interface has been disabled for lack of
a legitimate use case.  If you have one, please send an email to
linux-mm@kvack.org.
Sep  2 14:17:29 nmlgosocialcass02 kernel: ip_tables: (C) 2000-2006
Netfilter Core Team
Sep  2 14:17:33 nmlgosocialcass02 abrtd: Generating core_backtrace
Sep  2 14:17:36 nmlgosocialcass02 abrtd: New problem directory
/var/spool/abrt/ccpp-2016-09-02-14:17:00-1330, processing
Sep  2 14:17:36 nmlgosocialcass02 abrtd: Sending an email...
Sep  2 14:17:36 nmlgosocialcass02 abrtd: Email was sent to: root@localhost

--001a11440b328817f2053b829032
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi,<br></div>=C2=A0 I am trying to start cassandra se=
rvice, and its start after 2-3 min its automatically killed, will you pleas=
e help me on this.<br><div><div><div><div><br><br>this is log what i get<br=
>-----------------------------<br>Sep=C2=A0 2 14:14:11 nmlgosocialcass02 ke=
rnel: TCP: TCP: Possible SYN flooding on port 9042. Sending cookies.=C2=A0 =
Check SNMP counters.<br>Sep=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: sd 0=
:1:0:0: [sda] Unhandled sense code<br>Sep=C2=A0 2 14:16:57 nmlgosocialcass0=
2 kernel: sd 0:1:0:0: [sda]=C2=A0 <br>Sep=C2=A0 2 14:16:57 nmlgosocialcass0=
2 kernel: Result: hostbyte=3DDID_OK driverbyte=3DDRIVER_SENSE<br>Sep=C2=A0 =
2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]=C2=A0 <br>Sep=C2=A0 =
2 14:16:57 nmlgosocialcass02 kernel: Sense Key : Medium Error [current] <br=
>Sep=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: Info fld=3D0x141fc62c<br>Se=
p=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]=C2=A0 <br>Se=
p=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: Add. Sense: Unrecovered read e=
rror<br>Sep=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] CD=
B: <br>Sep=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: Read(10): 28 00 28 3f=
 8c a8 00 00 80 00<br>Sep=C2=A0 2 14:16:57 nmlgosocialcass02 kernel: end_re=
quest: critical target error, dev sda, sector 675253416<br>Sep=C2=A0 2 14:1=
7:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda] Unhandled sense code<br>Se=
p=C2=A0 2 14:17:00 nmlgosocialcass02 kernel: sd 0:1:0:0: [sda]=C2=A0 <br>Se=
p=C2=A0 2 14:17:00 nmlgosocialcass02 kernel: Result: hostbyte=3DDID_OK driv=
erbyte=3DDRIVER_SENSE<br>Sep=C2=A0 2 14:17:00 nmlgosocialcass02 kernel: sd =
0:1:0:0: [sda]=C2=A0 <br>Sep=C2=A0 2 14:17:00 nmlgosocialcass02 kernel: Sen=
se Key : Medium Error [current] <br>Sep=C2=A0 2 14:17:00 nmlgosocialcass02 =
kernel: Info fld=3D0x141fc62c<br>Sep=C2=A0 2 14:17:00 nmlgosocialcass02 ker=
nel: sd 0:1:0:0: [sda]=C2=A0 <br>Sep=C2=A0 2 14:17:00 nmlgosocialcass02 ker=
nel: Add. Sense: Unrecovered read error<br>Sep=C2=A0 2 14:17:00 nmlgosocial=
cass02 kernel: sd 0:1:0:0: [sda] CDB: <br>Sep=C2=A0 2 14:17:00 nmlgosocialc=
ass02 kernel: Read(10): 28 00 28 3f 8c a8 00 00 08 00<br>Sep=C2=A0 2 14:17:=
00 nmlgosocialcass02 kernel: end_request: critical target error, dev sda, s=
ector 675253416<br>Sep=C2=A0 2 14:17:23 nmlgosocialcass02 abrt[1957]: Saved=
 core dump of pid 1330 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.91-3.b14.el6_=
8.x86_64/jre/bin/java) to /var/spool/abrt/ccpp-2016-09-02-14:17:00-1330 (95=
70549760 bytes)<br>Sep=C2=A0 2 14:17:23 nmlgosocialcass02 abrt[1957]: /var/=
spool/abrt is 19120585808 bytes (more than 1535MiB), deleting &#39;ccpp-201=
6-08-29-16:36:28-13346&#39;<br>Sep=C2=A0 2 14:17:23 nmlgosocialcass02 abrtd=
: Directory &#39;ccpp-2016-09-02-14:17:00-1330&#39; creation detected<br>Se=
p=C2=A0 2 14:17:29 nmlgosocialcass02 kernel: nr_pdflush_threads exported in=
 /proc is scheduled for removal<br>Sep=C2=A0 2 14:17:29 nmlgosocialcass02 k=
ernel: sysctl: The scan_unevictable_pages sysctl/node-interface has been di=
sabled for lack of a legitimate use case.=C2=A0 If you have one, please sen=
d an email to <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.=
<br>Sep=C2=A0 2 14:17:29 nmlgosocialcass02 kernel: ip_tables: (C) 2000-2006=
 Netfilter Core Team<br>Sep=C2=A0 2 14:17:33 nmlgosocialcass02 abrtd: Gener=
ating core_backtrace<br>Sep=C2=A0 2 14:17:36 nmlgosocialcass02 abrtd: New p=
roblem directory /var/spool/abrt/ccpp-2016-09-02-14:17:00-1330, processing<=
br>Sep=C2=A0 2 14:17:36 nmlgosocialcass02 abrtd: Sending an email...<br>Sep=
=C2=A0 2 14:17:36 nmlgosocialcass02 abrtd: Email was sent to: root@localhos=
t<br><br></div></div></div></div></div>

--001a11440b328817f2053b829032--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
