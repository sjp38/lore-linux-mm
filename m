Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC628E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:43:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b24so1976083pls.11
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:43:11 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id y17si5735542pgh.353.2018.12.20.10.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 10:43:10 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
Date: Thu, 20 Dec 2018 18:43:08 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075014642388B@US01WEMBX2.internal.synopsys.com>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
 <1545239047.14089.13.camel@synopsys.com>
 <49f9edc9-87ee-1efc-58f8-b0d9a52c8a49@synopsys.com>
 <e2d2c160-0ef6-5504-7824-032a5c70fa7f@I-love.SAKURA.ne.jp>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 12/20/18 5:30 AM, Tetsuo Handa wrote:=0A=
>> | Stack Trace:=0A=
>> |  arc_unwind_core+0xcc/0x100=0A=
>> |  ___might_sleep+0x17a/0x190=0A=
>> |  mmput+0x16/0xb8=0A=
> Then, does mmput_async() help?=0A=
>=0A=
=0A=
It helps, but then we get the next one (w/o my patch 2/2)=0A=
=0A=
BUG: sleeping function called from invalid context at kernel/locking/rwsem.=
c:23=0A=
in_atomic(): 1, irqs_disabled(): 0, pid: 69, name: segv-null-ptr=0A=
no locks held by segv-null-ptr/69.=0A=
CPU: 0 PID: 69 Comm: segv-null-ptr Not tainted 4.18.0+ #72=0A=
=0A=
Stack Trace:=0A=
  arc_unwind_core+0xcc/0x100=0A=
  ___might_sleep+0x17a/0x190=0A=
  down_read+0x18/0x38=0A=
  show_regs+0x102/0x310=0A=
  get_signal+0x5ee/0x610=0A=
  do_signal+0x2c/0x218=0A=
  resume_user_mode_begin+0x90/0xd8=0A=
    @off 0x103d4 in [/segv-null-pt=0A=
