Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27CCC800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 12:48:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o16so2861238pgv.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:48:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h132sor1457005pfe.34.2018.01.24.09.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 09:48:22 -0800 (PST)
From: Joel Fernandes <joelaf@google.com>
Subject: Re: possible deadlock in shmem_file_llseek
Date: Wed, 24 Jan 2018 09:47:23 -0800
Message-Id: <20180124174723.25289-1-joelaf@google.com>
In-Reply-To: <001a1144d6e854b3c90562668d74@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>, hughd@google.com, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com
Cc: Dmitry Vyukov <dvyukov@google.com>, Joel Fernandes <joelaf@google.com>


#syz test: https://github.com/joelagnel/linux.git test-ashmem

--->8----
