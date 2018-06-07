Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 143D16B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:52:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v5-v6so4584768wmh.6
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:52:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g18-v6si283966edm.273.2018.06.07.04.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 04:52:43 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w57BmtU4043258
	for <linux-mm@kvack.org>; Thu, 7 Jun 2018 07:52:41 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jf383tqdn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:52:41 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 7 Jun 2018 12:52:39 +0100
Date: Thu, 7 Jun 2018 14:52:33 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx>
 <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
Message-Id: <20180607115232.GA8245@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: pasha.tatashin@oracle.com, linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

On Thu, Jun 07, 2018 at 11:58:05AM +0300, Timofey Titovets wrote:
> D2N?, 29 D 1/4 D?N? 2018 D3. D2 17:46, Pavel Tatashin <pasha.tatashin@oracle.com>:
> >
> > > What about moving choice_fastest_hash() to run_store()?
> >
> > > KSM anyway starts with ksm_run = KSM_RUN_STOP and does not scan until
> > > userspace writes !0 to /sys/kernel/mm/ksm/run.
> >
> > > Selection of the hash function when KSM is actually enabled seems quite
> > > appropriate...
> >
> > Hi Mike,
> >
> > This is a good idea to select hash function from run_store() when (flags &
> > KSM_RUN_MERGE) is set for the first time.
> >
> > Pavel
> 
> IIRC, run_store hidden under '#ifdef CONFIG_SYSFS'
> So, what's about case without CONFIG_SYSFS?

With CONFIG_SYSFS=n there is nothing that will set ksm_run to anything but
zero and ksm_do_scan will never be called.
 
> -- 
> Have a nice day,
> Timofey.
> 

-- 
Sincerely yours,
Mike.
