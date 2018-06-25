Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5BF6B0008
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 04:48:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l17-v6so8989930wrm.3
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 01:48:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i82-v6si2598151wmd.3.2018.06.25.01.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 01:48:18 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5P8iCLM032277
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 04:48:16 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jtqwwbxea-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 04:48:16 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 25 Jun 2018 09:48:14 +0100
Date: Mon, 25 Jun 2018 11:48:07 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
References: <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx>
 <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
 <20180607115232.GA8245@rapoport-lnx>
 <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
Message-Id: <20180625084806.GB13791@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, solee@os.korea.ac.kr, aarcange@redhat.com, kvm@vger.kernel.org

On Thu, Jun 07, 2018 at 09:29:49PM -0400, Pavel Tatashin wrote:
> > With CONFIG_SYSFS=n there is nothing that will set ksm_run to anything but
> > zero and ksm_do_scan will never be called.
> >
> 
> Unfortunatly, this is not so:
> 
> In: /linux-master/mm/ksm.c
> 
> 3143#else
> 3144 ksm_run = KSM_RUN_MERGE; /* no way for user to start it */
> 3145
> 3146#endif /* CONFIG_SYSFS */
> 
> So, we do set ksm_run to run right from ksm_init() when CONFIG_SYSFS=n.
> 
> I wonder if this is acceptible to only use xxhash when CONFIG_SYSFS=n ?

BTW, with CONFIG_SYSFS=n KSM may start running before hardware acceleration
for crc32c is initialized...
 
> Thank you,
> Pavel
> 

-- 
Sincerely yours,
Mike.
