Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8882E6B00B9
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 20:31:30 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ty20so2402662lab.39
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 17:31:29 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
        by mx.google.com with ESMTPS id eq2si8477771lac.127.2014.06.26.17.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 17:31:28 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id n15so3441443lbi.6
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 17:31:28 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 26 Jun 2014 17:31:07 -0700
Message-ID: <CALCETrV4YLCu2RUStCLVfaRzd3zYjWptLmgxK0B7LxzLgov1UA@mail.gmail.com>
Subject: Where's my special mapping?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Tongue in cheek subject aside, this is a serious question.  How can I
reliably find a special mapping?

AFAICS every architecture that uses special mappings keeps track of
the location in mm->context.  This is buggy because mremap can move
the special mapping.

Most architectures only use it for arch_vma_name, which is a silly
function anyway: _install_special_mapping avoids the need for it.  But
32-bit x86 (compat and native) needs to find the vdso at runtime.  Is
there any good way to do this?

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
