Received: by zproxy.gmail.com with SMTP id k1so536543nzf
        for <linux-mm@kvack.org>; Sat, 22 Oct 2005 09:09:44 -0700 (PDT)
Message-ID: <f68e01850510220909wad86b06wadc620fb5f807b5d@mail.gmail.com>
Date: Sat, 22 Oct 2005 21:39:43 +0530
From: Nitin Gupta <nitingupta.mail@gmail.com>
Subject: a basic question
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
    These are the questions that have been troubling me for long time.
I'm beginning to work on a vmm project, so kindly spare a min to
answer these:

- How does processor know that 3GB-4GB is mapped linearly on first 1GB
of memory. Is there a pagetable for this segment mapping it linearly?

- Why isn't it like this  - userspace tasks have 4GB virtual address
space and for kernel also a 4GB virtual address space that is linearly
mapped to fist 4GB of memory.


Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
