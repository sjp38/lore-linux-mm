Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABC8F6B0008
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:49:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 189-v6so3856322ita.1
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:49:05 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o22-v6si5356592ioh.129.2018.06.22.11.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 11:49:04 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5MIn3fJ055876
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:49:03 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2jrp8eu4qt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:49:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5MIn2Tj008361
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:49:02 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5MIn2Yj009959
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:49:02 GMT
Received: by mail-ot0-f178.google.com with SMTP id i19-v6so8567496otk.10
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:49:02 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain> <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx> <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
 <20180607115232.GA8245@rapoport-lnx> <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
 <20180610053838.GB20681@rapoport-lnx>
In-Reply-To: <20180610053838.GB20681@rapoport-lnx>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 22 Jun 2018 14:48:25 -0400
Message-ID: <CAGM2rebLK4he+EKSoT4vWYn1X_F6PESzrN0jM44FBX7wkO7pRQ@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, solee@os.korea.ac.kr, aarcange@redhat.com, kvm@vger.kernel.org

> A bit unrelated to CONFIG_SYSFS, but rather for rare use-cases in general.
> What will happen in the following scenario:
>
> * The system has crc32c HW acceleration
> * KSM chooses crc32c
> * KSM runs with crc32c
> * user removes crc32c HW acceleration module
>
> If I understand correctly, we'll then fall back to pure SW crc32c
> calculations, right?

Yes, we fallback to the SW crc32c, which is slower compared to hw
optimized, but we won't change hash function once it is set. I do not
think it makes sense to add any extra logic into ksm for that, even
after every page is unmerged and ksm thread is stopped.

Pavel
