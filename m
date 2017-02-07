Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E50D76B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 13:57:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so155314029pfg.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 10:57:23 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 69si4878439plk.81.2017.02.07.10.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 10:57:23 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id C3DCE2034B
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 18:57:21 +0000 (UTC)
Received: from mail-ua0-f177.google.com (mail-ua0-f177.google.com [209.85.217.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9E6DF20303
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 18:57:20 +0000 (UTC)
Received: by mail-ua0-f177.google.com with SMTP id 35so91848797uak.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 10:57:20 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 7 Feb 2017 10:56:59 -0800
Message-ID: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
Subject: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Quite a few people have expressed interest in enabling PCID on (x86)
Linux.  Here's the code:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid

The main hold-up is that the code needs to be reviewed very carefully.
It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
entries using PCID" ought to be looked at carefully to make sure the
locking is right, but there are plenty of other ways this this could
all break.

Anyone want to take a look or maybe scare up some other reviewers?
(Kees, you seemed *really* excited about getting this in.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
