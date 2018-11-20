Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8696B2239
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 17:17:04 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y83so4831720qka.7
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 14:17:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s10sor45934722qvs.25.2018.11.20.14.17.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 14:17:03 -0800 (PST)
Date: Tue, 20 Nov 2018 17:16:59 -0500
From: Dennis Zhou <dennis@kernel.org>
Subject: LPC Traffic Shaping w/ BPF Talk - percpu followup
Message-ID: <20181120221659.GA61322@dennisz-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eddie Hao <eddieh@google.com>, Vlad Dumitrescu <vladum@google.com>, Willem de Bruijn <willemb@google.com>
Cc: Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Eddie, Vlad, and Willem,

A few people mentioned to me that you guys were experiencing issues with
the percpu memory allocator. I saw the talk slides mention the
following two bullets:

1) allocation pattern makes the per cpu allocator reach a highly
   fragmented state
2) sometimes takes a long time (up to 12s) to create the PERCPU_HASH
   maps at startup

Could you guys elaborate a little more about the above? Some things
that would help: kernel version, cpu info, and a reproducer if possible?

Also, I did some work last summer to make percpu allocation more
efficient, which went into the 4.14 kernel. Just to be sure, is that a
part of the kernel you guys are running?

Thanks,
Dennis
