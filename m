Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id CE4646B007E
	for <linux-mm@kvack.org>; Sat, 26 Mar 2016 15:39:58 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id qe11so62733537lbc.3
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 12:39:58 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id p9si10685964lfe.196.2016.03.26.12.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Mar 2016 12:39:57 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id q73so69260200lfe.2
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 12:39:57 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 27 Mar 2016 00:09:56 +0430
Message-ID: <CA+5nn1gfsuY50ZuqnM_O5na4c0P4pAw2wikez2k_a9xA+08i1Q@mail.gmail.com>
Subject: Tracing Accesses to the Page Cache
From: Mujtaba Tarihi <mujtaba.tarihi@gmail.com>
Content-Type: multipart/alternative; boundary=001a113eaf3225ef7a052ef8d854
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a113eaf3225ef7a052ef8d854
Content-Type: text/plain; charset=UTF-8

Dear All,

I have been trying to devise a method to trace *all* accesses to the page
cache. This includes reads and writes to pages that are already present in
the page cache (which will not be observed if the dirty/referenced bit have
not been reset yet by the shrink_list functionality). What I have thought
of is implementing a driver similar to the kmmiotrace but for page cache.

What kmmiotrace does is resetting the present bit on PDEs related to a
device driver. When the device in question is hit, kmmiotrace has a code
path for page fault where is checks if the device being traced is the one
we are interested in.
It then records the information of the location addressing the memory, puts
the system in single-stepping mode, waits for the next trap and resets the
present bit for the remaining accesses. It also terminates the
single-stepping mode.

What I am thinking of is implementing a similar, but wholesale scheme for
all pages within the page cache. In other words, when a page resides in the
page cache, one of the bits (I am thinking of the resetting all access
permission bits so a read/write would trigger a GPF), then I would proceed
as the kmmiotrace.
I am aware of the massive performance penalty that this methodology
probably entails but I am interested in observing each and every access
within the page cache.

I wanted to ask the people who obviously know more than me about Linux
memory management about how logical such an attempt would be and whether
there is a better way that I have missed.

Thanks very much in advance!

--001a113eaf3225ef7a052ef8d854
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Dear All,<div><br></div><div>I have been trying to devise =
a method to trace *all* accesses to the page cache. This includes reads and=
 writes to pages that are already present in the page cache (which will not=
 be observed if the dirty/referenced bit have not been reset yet by the shr=
ink_list functionality). What I have thought of is implementing a driver si=
milar to the kmmiotrace but for page cache.</div><div><br></div><div>What k=
mmiotrace does is resetting the present bit on PDEs related to a device dri=
ver. When the device in question is hit, kmmiotrace has a code path for pag=
e fault where is checks if the device being traced is the one we are intere=
sted in.<br></div><div>It then records the information of the location addr=
essing the memory, puts the system in single-stepping mode, waits for the n=
ext trap and resets the present bit for the remaining accesses. It also ter=
minates the single-stepping mode.</div><div><br></div><div>What I am thinki=
ng of is implementing a similar, but wholesale scheme for all pages within =
the page cache. In other words, when a page resides in the page cache, one =
of the bits (I am thinking of the resetting all access permission bits so a=
 read/write would trigger a GPF), then I would proceed as the kmmiotrace.</=
div><div>I am aware of the massive performance penalty that this methodolog=
y probably entails but I am interested in observing each and every access w=
ithin the page cache.</div><div><br></div><div>I wanted to ask the people w=
ho obviously know more than me about Linux memory management about how logi=
cal such an attempt would be and whether there is a better way that I have =
missed.</div><div><br></div><div>Thanks very much in advance!</div></div>

--001a113eaf3225ef7a052ef8d854--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
