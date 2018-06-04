Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8B356B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 00:58:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j18-v6so3790366wme.5
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 21:58:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i132-v6si5720730wma.19.2018.06.03.21.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jun 2018 21:58:23 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w544s9XH135707
	for <linux-mm@kvack.org>; Mon, 4 Jun 2018 00:58:21 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jctv57069-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Jun 2018 00:58:21 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 4 Jun 2018 05:58:20 +0100
Date: Mon, 4 Jun 2018 07:58:12 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
 <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
 <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com>
Message-Id: <20180604045812.GA15196@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Mon, Jun 04, 2018 at 10:41:10AM +0800, c|1e??e?(R) wrote:
> Hi Tetsuo
> > Since origin_memcg_name is printed for both memcg OOM and !memcg OOM, it is strange that origin_memcg_name is updated only when memcg != NULL. Have you really tested !memcg OOM case?
> 
> if memcg == NULL , origin_memcg_name will also be NULL, so the length
> of it is 0. origin_memcg_name will be "(null)". I've tested !memcg OOM
> case with CONFIG_MEMCG and !CONFIG_MEMCG, and found nothing wrong.
> 
> Thanks
> Wind
> c|1e??e?(R) <ufo19890607@gmail.com> ao?2018a1'6ae??4ae?JPYa??a,? a,?a??9:58a??e??i 1/4 ?
> >
> > Hi Mike
> > > Please keep the brief description of the function actually brief and move the detailed explanation after the parameters description.
> > Thanks for your advice.
> >
> > > The allocation constraint is detected by the dump_header() callers, why not just use it here?
> > David suggest that constraint need to be printed in the oom report, so
> > I add the enum variable in this function.

My question was why do you call to alloc_constrained in the dump_header()
function rather than pass the constraint that was detected a bit earlier to
that function? 

Sorry if wasn't clear enough.

> > Thanks
> > Wind
> 

-- 
Sincerely yours,
Mike.
