Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 68A7A6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 13:19:18 -0400 (EDT)
Received: by iofz202 with SMTP id z202so130688896iof.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 10:19:18 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id u83si16671761ioi.16.2015.10.23.10.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 10:19:17 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so129075781pac.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 10:19:17 -0700 (PDT)
Received: from [192.168.123.149] ([116.121.77.221])
        by smtp.gmail.com with ESMTPSA id ug4sm20024615pac.11.2015.10.23.10.19.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Oct 2015 10:19:16 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: 'atom_size' configuration when a generic setup_per_cpu_ares() is used
Date: Sat, 24 Oct 2015 02:19:13 +0900
Message-Id: <7E527DCB-C2D1-47D7-A57A-88D37DFEDAD6@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Greetings,

Nowadays I'm working on 'IRQ Stack' on ARM64 [1]. Like x86, I'd like to
utilize percpu infrastructure for stack allocation, but I've got a challenge.

ARM64 uses a generic setup_per_cpu_areas() described in mm/percpu.c. IOW,
__per_cpu_offset[] is PAGE_SIZE aligned, and it is not possible to allocate
stack with an alignment which is bigger than PAGE_SIZE. At first glance,
the alignment of __per_cpu_offset[] looks controlled by 'atom_size' argument
of pcpu_embed_first_chunk(), but I soon realize that the 'atom_size' is not
configurable in this case.

It would be redundant to introduce ARM64-specific setup_per_cpu_areas() for
a single parameter, atom_size, change. At the same time, it is doubtable to
define an interface, like PERCPU_ENOUGH_ROOM [2], for a single arch support.
I'm not sure which approach is better than the other.

Any comments are greatly welcome.

Thanks in advance!

[1] https://lkml.org/lkml/2015/10/17/75
[2] Since no code uses PERCPU_ENOUGH_ROOM, it could be dropped as clean-up.

--
Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
