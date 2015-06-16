Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 208B46B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:37:16 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so6352251pdb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:37:15 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id kl8si21103037pdb.48.2015.06.15.22.37.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jun 2015 22:37:15 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <kamalesh@linux.vnet.ibm.com>;
	Tue, 16 Jun 2015 11:07:11 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6AF96E004C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 11:10:38 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5G5bA6w9765146
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 11:07:10 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5G5b9B3013691
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 11:07:09 +0530
Date: Tue, 16 Jun 2015 11:07:04 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at
 kernel/sched/core.c:7318
Message-ID: <20150616053702.GA29055@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Tejun Heo <tj@kernel.org>, Martin KaFai Lau <kafai@fb.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

* Larry Finger <Larry.Finger@lwfinger.net> [2015-06-15 16:25:18]:

> Beginning at commit d52d399, the following INFO splat is logged:
> 

[...]

> ---
>  include/linux/kmemleak.h |  3 ++-
>  mm/kmemleak.c            |  9 +++++----
>  mm/kmemleak.c.rej        | 19 +++++++++++++++++++
>  mm/percpu.c              |  2 +-
>  4 files changed, 27 insertions(+), 6 deletions(-)
>  create mode 100644 mm/kmemleak.c.rej

Patch creates kmemleak.c.rej file.


Regards,
Kamalesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
