Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 596386B006E
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 06:11:15 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id b14so9682340qcs.10
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 03:11:14 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Sat, 5 Jan 2013 12:11:14 +0100
Message-ID: <CA+icZUVpK2NLUd2tGnvq8y-CWUGk1UDQsso5SQRPPZgp7=ekQA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: mmap: annotate vm_lock_anon_vma locking properly
 for lockdep
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Jiri,

see my other reply to "[PATCH 1/2] lockdep, rwsem: provide
down_write_nest_lock()" in [1]...

...and feel free to add...

     Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

Thanks!

Regards,
- Sedat -

[1] http://marc.info/?l=linux-mm&m=135738411200967&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
