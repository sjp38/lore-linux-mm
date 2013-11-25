Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1E16B0037
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:35:40 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id if17so3205855vcb.25
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:35:40 -0800 (PST)
Received: from mail-vb0-f44.google.com (mail-vb0-f44.google.com [209.85.212.44])
        by mx.google.com with ESMTPS id dk5si18511082vcb.146.2013.11.25.15.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:35:39 -0800 (PST)
Received: by mail-vb0-f44.google.com with SMTP id w20so3412053vbb.3
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:35:39 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Nov 2013 15:35:18 -0800
Message-ID: <CALCETrVsZfHqKT-+SHBq7kYx-_3Gvr=mUYUw81uvNuiMxgLWNA@mail.gmail.com>
Subject: Setting stack NUMA policy?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I'm trying to arrange for a process to have a different memory policy
on its stack as compared to everything else (e.g. mapped libraries).
Before I start looking for kludges, is there any clean way to do this?

So far, the best I can come up with is to either parse /proc/self/maps
on startup or to deduce the stack range from the stack pointer and
then call mbind.  Then, for added fun, I'll need to hook mmap so that
I can mbind MAP_STACK vmas that are created for threads.

This is awful.  Is there something better?

(What I really want is a separate policy for MAP_SHARED vs MAP_PRIVATE.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
