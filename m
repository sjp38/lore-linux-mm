Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4319D6B0271
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:51:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 82so93783936ioh.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:51:01 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id i123si6740461ioi.78.2016.09.22.22.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 22:51:00 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id n143so396286ita.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:51:00 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160919094224.GH10785@dhcp22.suse.cz>
Date: Thu, 22 Sep 2016 11:30:36 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
References: <20160911222411.GA2854@janani-Inspiron-3521> <20160912121635.GL14524@dhcp22.suse.cz> <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com> <20160919094224.GH10785@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org


> On Sep 19, 2016, at 5:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Tue 13-09-16 14:04:49, Janani Ravichandran wrote:
>>=20
>>> On Sep 12, 2016, at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>=20
>> I=E2=80=99m using the function graph tracer to see how long =
__alloc_pages_nodemask()
>> took.
>=20
> How can you map the function graph tracer to a specif context? Let's =
say
> I would like to know why a particular allocation took so long. Would
> that be possible?

Maybe not. If the latencies are due to direct reclaim or memory =
compaction, you
get some information from the tracepoints (like =
mm_vmscan_direct_reclaim_begin,
mm_compaction_begin, etc). But otherwise, you don=E2=80=99t get any =
context information.=20
Function graph only gives the time spent in alloc_pages_nodemask() in =
that case.


Regards,
Janani.
>=20
> --=20
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
