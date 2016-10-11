Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 399B86B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 10:43:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z54so16325719qtz.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 07:43:52 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id u63si1589262qka.196.2016.10.11.07.43.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 07:43:30 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id f128so978430qkb.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 07:43:23 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160923080709.GB4478@dhcp22.suse.cz>
Date: Tue, 11 Oct 2016 10:43:20 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
References: <20160911222411.GA2854@janani-Inspiron-3521> <20160912121635.GL14524@dhcp22.suse.cz> <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com> <20160919094224.GH10785@dhcp22.suse.cz> <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com> <20160923080709.GB4478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org

Hi Michal,

>=20
Extremely sorry for the delayed response.

> Then I really think that we need a starting trace point. I think that
> having the full context information is really helpful in order to
> understand latencies induced by allocations.
> =E2=80=94=20

Alright. I=E2=80=99ll add a starting tracepoint, change the script =
accordingly and=20
send a v2. Thanks!

Regards,
Janani.
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
