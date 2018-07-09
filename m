Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3BC6B02F6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:05:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c1-v6so21824794qtj.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:05:49 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id y191-v6si1101535qkb.119.2018.07.09.09.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Jul 2018 09:05:48 -0700 (PDT)
Date: Mon, 9 Jul 2018 16:05:47 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: kernel BUG at mm/slab.c:LINE! (2)
In-Reply-To: <000000000000afa87d05708af289@google.com>
Message-ID: <010001647fcab0b9-1154d4da-94f8-404e-8898-b8acdf366592-000000@email.amazonses.com>
References: <000000000000afa87d05708af289@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+885bda95271928dc24eb@syzkaller.appspotmail.com>
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Sun, 8 Jul 2018, syzbot wrote:

> kernel BUG at mm/slab.c:4421!

Classic location that indicates memory corruption. Can we rerun this with
CONFIG_SLAB_DEBUG? Alternatively use SLUB debugging for better debugging
without rebuilding.
