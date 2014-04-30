Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3E29D6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 23:31:40 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id eb12so1321770oac.2
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 20:31:39 -0700 (PDT)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id c10si17935605oed.199.2014.04.29.20.31.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 20:31:39 -0700 (PDT)
Received: by mail-ob0-f178.google.com with SMTP id wn1so1341527obc.9
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 20:31:39 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 29 Apr 2014 23:31:38 -0400
Message-ID: <CAG4AFWaemUiR1HTx5dUUQf3V4twuwuiBdtDLNEeEoF-ikTThpQ@mail.gmail.com>
Subject: Is heap_stack_gap useless?
From: Jidong Xiao <jidong.xiao@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b472148b4dfed04f83a2f75
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernel development list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

--047d7b472148b4dfed04f83a2f75
Content-Type: text/plain; charset=UTF-8

Hi,

I noticed this variable, defined in mm/nommu.c,

mm/nommu.c:int heap_stack_gap = 0;

This variable only shows up once, and never shows up in elsewhere.

Can some one tell me is this useless? If so, I will submit a patch to
remove it.

-Jidong

--047d7b472148b4dfed04f83a2f75
Content-Type: text/html; charset=UTF-8

<div dir="ltr"><div>Hi,</div><div><br></div><div>I noticed this variable, defined in mm/nommu.c,</div><div><br></div>mm/nommu.c:int heap_stack_gap = 0;<br><div><br></div><div>This variable only shows up once, and never shows up in elsewhere.</div>
<div><br></div><div>Can some one tell me is this useless? If so, I will submit a patch to remove it.</div><div><br></div><div>-Jidong</div></div>

--047d7b472148b4dfed04f83a2f75--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
