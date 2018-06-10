Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC206B0003
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 01:12:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a15-v6so10238643wrr.23
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 22:12:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 65-v6si37952296wrp.70.2018.06.09.22.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 22:12:27 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5A59SS3075524
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 01:12:26 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jgv4ft5qq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 01:12:26 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 10 Jun 2018 06:12:24 +0100
Date: Sun, 10 Jun 2018 08:12:16 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
 <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
 <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com>
 <20180604045812.GA15196@rapoport-lnx>
 <CAHCio2gj-DoOek0RN718TCLZsOpNPd6Ua88HPijdqezuySDjaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2gj-DoOek0RN718TCLZsOpNPd6Ua88HPijdqezuySDjaw@mail.gmail.com>
Message-Id: <20180610051215.GA20681@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Fri, Jun 08, 2018 at 05:53:14PM +0800, c|1e??e?(R) wrote:
> Hi Mike
> > My question was why do you call to alloc_constrained in the dump_header()
> > function rather than pass the constraint that was detected a bit earlier to
> > that function?
> 
> dump_header will be called by three functions: oom_kill_process,
> check_panic_on_oom, out_of_memory.
> We can get the constraint from the last two
> functions(check_panic_on_oom, out_of_memory), but I need to
> pass a new parameter(constraint) for oom_kill_process.

Another option is to add the constraint to the oom_control structure.
 
> Thanks
> 

-- 
Sincerely yours,
Mike.
