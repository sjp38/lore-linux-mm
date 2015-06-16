Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8878D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 02:02:14 -0400 (EDT)
Received: by oigx81 with SMTP id x81so4714941oig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:02:14 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id 67si10091854oid.129.2015.06.15.23.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 23:02:13 -0700 (PDT)
Received: by obcej4 with SMTP id ej4so4750212obc.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:02:13 -0700 (PDT)
Message-ID: <557FBBE1.2060301@lwfinger.net>
Date: Tue, 16 Jun 2015 01:02:09 -0500
From: Larry Finger <Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at kernel/sched/core.c:7318
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net> <20150616053702.GA29055@linux.vnet.ibm.com>
In-Reply-To: <20150616053702.GA29055@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, Martin KaFai Lau <kafai@fb.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/16/2015 12:37 AM, Kamalesh Babulal wrote:
> * Larry Finger <Larry.Finger@lwfinger.net> [2015-06-15 16:25:18]:
>
>> Beginning at commit d52d399, the following INFO splat is logged:
>>
>
> [...]
>
>> ---
>>   include/linux/kmemleak.h |  3 ++-
>>   mm/kmemleak.c            |  9 +++++----
>>   mm/kmemleak.c.rej        | 19 +++++++++++++++++++
>>   mm/percpu.c              |  2 +-
>>   4 files changed, 27 insertions(+), 6 deletions(-)
>>   create mode 100644 mm/kmemleak.c.rej
>
> Patch creates kmemleak.c.rej file.

Sorry about that. This one was an RFC. I'll fix that before the final submission.

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
