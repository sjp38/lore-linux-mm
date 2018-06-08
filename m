Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95A666B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:30:10 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id a10-v6so8753271iod.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:30:10 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x2-v6si6691933iof.146.2018.06.07.18.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 18:30:09 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w581Kmpq081418
	for <linux-mm@kvack.org>; Fri, 8 Jun 2018 01:30:08 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2jbvypb4rq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 08 Jun 2018 01:30:08 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w581U6W5019725
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 8 Jun 2018 01:30:06 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w581U6B9028976
	for <linux-mm@kvack.org>; Fri, 8 Jun 2018 01:30:06 GMT
Received: by mail-ot0-f182.google.com with SMTP id q17-v6so13846101otg.2
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:30:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx> <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com> <20180607115232.GA8245@rapoport-lnx>
In-Reply-To: <20180607115232.GA8245@rapoport-lnx>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 7 Jun 2018 21:29:49 -0400
Message-ID: <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, solee@os.korea.ac.kr, aarcange@redhat.com, kvm@vger.kernel.org

> With CONFIG_SYSFS=n there is nothing that will set ksm_run to anything but
> zero and ksm_do_scan will never be called.
>

Unfortunatly, this is not so:

In: /linux-master/mm/ksm.c

3143#else
3144 ksm_run = KSM_RUN_MERGE; /* no way for user to start it */
3145
3146#endif /* CONFIG_SYSFS */

So, we do set ksm_run to run right from ksm_init() when CONFIG_SYSFS=n.

I wonder if this is acceptible to only use xxhash when CONFIG_SYSFS=n ?

Thank you,
Pavel
