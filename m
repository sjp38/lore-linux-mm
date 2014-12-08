Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 97A646B0038
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 23:24:07 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id f51so2974848qge.4
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 20:24:07 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com. [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id q8si42215992qco.8.2014.12.07.20.24.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 20:24:06 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id dc16so2949390qab.11
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 20:24:06 -0800 (PST)
Received: from ?IPv6:2601:0:8980:d30:2ab2:bdff:fe8b:6136? ([2601:0:8980:d30:2ab2:bdff:fe8b:6136])
        by mx.google.com with ESMTPSA id c107sm19739245qgf.11.2014.12.07.20.24.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Dec 2014 20:24:05 -0800 (PST)
Message-ID: <548527E3.6040104@gmail.com>
Date: Sun, 07 Dec 2014 23:24:03 -0500
From: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
MIME-Version: 1.0
Subject: Questions about mm
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello everyone,

I have some questions about page allocation and locking.

- Suppose that a process is about to be killed and before that happens, I want
to keep the content of the page intact in the memory, i.e. the page should
neither be zeored or allocated to some other process unless required. In order
to achieve this, what can be the most optimal approach in which the internals of
the kernel is not changed besides adding a syscall or something.

- Another is what happens if I increase the count of mm_users and mm_count
before and later that process gets killed. Assuming that the mm was linked only
to the killed process. What will happen in this case?

- Last question that I wanted to know is what will happen if I change the flags
of the pages to be reserved and unevictable?
Is it possible for the pages to be set pinned as well?
Can this approach help me soling the first issue or I might get a BUG by some
other component in kernel?

Since, I have just started playing with the kernel, so there is a possibility
that I might have asked something very silly/horrific. Please bear with me.

Thanks,
Sanidhya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
