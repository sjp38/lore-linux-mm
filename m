Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC336B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 20:50:06 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id z60so2082572qgd.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:50:05 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id y7si11963693qci.59.2014.04.30.17.50.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 17:50:05 -0700 (PDT)
Received: by mail-qc0-f169.google.com with SMTP id e16so215540qcx.14
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:50:05 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 1 May 2014 08:50:05 +0800
Message-ID: <CALWv5jRnZZfo=3M810BXVNYQn95T_Mn47_hp6UhgVysjPcDtMA@mail.gmail.com>
Subject: sysctl made a dmesg message
From: Iru Cai <mytbk920423@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bdcaaa6c2e6ab04f84c0b4e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--047d7bdcaaa6c2e6ab04f84c0b4e
Content-Type: text/plain; charset=UTF-8

When I ran 'sysctl -w net.ipv6.conf.all.forwarding=1', I saw the following
in dmesg output.

[ 1368.082196] sysctl: The scan_unevictable_pages sysctl/node-interface has
been disabled for lack of a legitimate use case.  If you have one, please
send an email to linux-mm@kvack.org.

What's more, in my Cubieboard3 using the linux-sunxi kernel, the set of
ipv6.conf.all.forwarding will disable my IPv6 access.

--047d7bdcaaa6c2e6ab04f84c0b4e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">When I ran &#39;sysctl -w net.ipv6.conf.all.forwarding=3D1=
&#39;, I saw the following in dmesg output.<br><div><div><br>[ 1368.082196]=
 sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled=
 for lack of a legitimate use case.=C2=A0 If you have one, please send an e=
mail to <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.<br>
<br></div><div>What&#39;s more, in my Cubieboard3 using the linux-sunxi ker=
nel, the set of ipv6.conf.all.forwarding will disable my IPv6 access.<br><b=
r></div></div></div>

--047d7bdcaaa6c2e6ab04f84c0b4e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
