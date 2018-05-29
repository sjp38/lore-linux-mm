Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDE4E6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 10:46:23 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g5-v6so13254566ioc.4
        for <linux-mm@kvack.org>; Tue, 29 May 2018 07:46:23 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z190-v6si32736195ioe.199.2018.05.29.07.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 07:46:22 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4TEf7gp194853
	for <linux-mm@kvack.org>; Tue, 29 May 2018 14:46:21 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2j6y189jur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 29 May 2018 14:46:21 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4TEkKhM028100
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 29 May 2018 14:46:20 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w4TEkJDb020992
	for <linux-mm@kvack.org>; Tue, 29 May 2018 14:46:19 GMT
Received: by mail-ot0-f174.google.com with SMTP id i5-v6so17258225otf.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 07:46:19 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com> <20180527130325.GB4522@rapoport-lnx>
In-Reply-To: <20180527130325.GB4522@rapoport-lnx>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 29 May 2018 10:45:42 -0400
Message-ID: <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, solee@os.korea.ac.kr, aarcange@redhat.com, kvm@vger.kernel.org

> What about moving choice_fastest_hash() to run_store()?

> KSM anyway starts with ksm_run = KSM_RUN_STOP and does not scan until
> userspace writes !0 to /sys/kernel/mm/ksm/run.

> Selection of the hash function when KSM is actually enabled seems quite
> appropriate...

Hi Mike,

This is a good idea to select hash function from run_store() when (flags &
KSM_RUN_MERGE) is set for the first time.

Pavel
