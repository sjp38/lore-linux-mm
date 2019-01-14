Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2A58E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 12:58:07 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p24so25419594qtl.2
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 09:58:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m64sor43035571qkd.41.2019.01.14.09.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 09:58:06 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
 <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
 <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
 <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
 <5298bfcc-0cbc-01e8-85b2-087a380fd3fe@lca.pw>
 <xeAUGwo5bQoLOJ9aXeSLY9G0hlKWJzjeZ4f4M1Hr8-1ryRwQ3Y-PgQ_eAtFAjpNZnn0zQGk6yHMkoEjjoM99vdhumv4Dey9KP5y6PvSRroo=@protonmail.ch>
From: Qian Cai <cai@lca.pw>
Message-ID: <51950f43-1daf-9192-ce9b-7a1ddae3edd2@lca.pw>
Date: Mon, 14 Jan 2019 12:58:03 -0500
MIME-Version: 1.0
In-Reply-To: <xeAUGwo5bQoLOJ9aXeSLY9G0hlKWJzjeZ4f4M1Hr8-1ryRwQ3Y-PgQ_eAtFAjpNZnn0zQGk6yHMkoEjjoM99vdhumv4Dey9KP5y6PvSRroo=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: "dgilbert@interlog.com" <dgilbert@interlog.com>, David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Unfortunately, I could not trigger any of those here both in a bare-metal and
virtual machines. All I triggered were hung tasks and soft-lockup due to fork bomb.

The only other thing I can think of is to setup kdump to capture a vmcore when
either GPF or BUG() happens, and then share the vmcore somewhere, so I might
pork around to see where the memory corruption looks like.
