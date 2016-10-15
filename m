Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1EF56B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 19:31:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w69so96263579qka.6
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 16:31:25 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id m52si13863958qta.84.2016.10.15.16.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 16:31:25 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id f128so180939831qkb.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 16:31:25 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
Date: Sat, 15 Oct 2016 19:31:22 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com>
References: <20160911222411.GA2854@janani-Inspiron-3521> <20160912121635.GL14524@dhcp22.suse.cz> <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com> <20160919094224.GH10785@dhcp22.suse.cz> <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com> <20160923080709.GB4478@dhcp22.suse.cz> <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Oct 11, 2016, at 10:43 AM, Janani Ravichandran =
<janani.rvchndrn@gmail.com> wrote:
>=20
> Alright. I=E2=80=99ll add a starting tracepoint, change the script =
accordingly and=20
> send a v2. Thanks!
>=20
I looked at it again and I think that the context information we need=20
can be obtained from the tracepoint trace_mm_page_alloc in=20
alloc_pages_nodemask().

I=E2=80=99ll include that tracepoint in the script and send it along =
with the other
changes you suggested, if you=E2=80=99re fine with it.

Thanks!
Janani.
>>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
