Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B216B6B0008
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 12:58:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g15so2738157pfi.8
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:58:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x15-v6si2012075plr.391.2018.04.20.09.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 09:58:54 -0700 (PDT)
Subject: Patch "ring-buffer: Check if memory is available before allocation" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Fri, 20 Apr 2018 18:58:17 +0200
Message-ID: <1524243497148137@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com, gregkh@linuxfoundation.org, huangzhaoyang@gmail.com, joelaf@google.com, linux-mm@kvack.org, rostedt@goodmis.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    ring-buffer: Check if memory is available before allocation

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     ring-buffer-check-if-memory-is-available-before-allocation.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
