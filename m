Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FBBC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BA5E206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:52:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="eMKx8OvZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BA5E206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 090FA6B0010; Wed,  3 Apr 2019 12:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0428B6B0266; Wed,  3 Apr 2019 12:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4BB46B0269; Wed,  3 Apr 2019 12:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 91F826B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:52:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17so7890038edd.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iGxxtIVqEzp1RVOI6u7Mj+o50/tLE0xJ0apojvzIrxc=;
        b=r3dB1clc9R3qs0cR8fGK3fEekwtD7hg54RaQaOntQRo3R0pvw43qKbSMZ2qd3jKH1K
         i/9qW35IZ0zUkxWD+nFPM2HnSa2c4co7EBip+4HV0Um7etBBdWT54P9X5mAdkluGkZd6
         WQcF8E6dFXHu72FgOrjMCwDAf3XzbkhUzrZNC/MPsYeLmjSMHFHLXTezZ540EdofvtKy
         IKSuj5NgJyBgpzOgANmnXrU4P8apQ/jbrCVgv5EnZf6wxmkE2vyNBwwwDkdKqIRnfGTG
         qNcSl/T7lbT6c/1nHoUp2Xj2xyQfp+Z/fApyuyfqq2mKLnsBnm4/JMImqqQ3cnBYW8XZ
         BliQ==
X-Gm-Message-State: APjAAAXm4djCaIFqakNAw5Sxf1gMv+0QihRboxObo4Wx+/Epx95PpFcY
	XxEWEaGGezS3RnZANWsfBPewJYJVwt6Y0BKsUPmwZtnHQInuounZN7D593D5S95O7glcIsXKfqy
	PTirNgLNCPjUyUURPNuS5wkBYgxsWIi9NBS5iW7jTh7FO1yTDospXc63e2q1RBDN+/A==
X-Received: by 2002:a50:cb4a:: with SMTP id h10mr450359edi.134.1554310372141;
        Wed, 03 Apr 2019 09:52:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8v5BK5HB/wNZwOmvU6dY5WT3rhkyBEt3jiDR0j7GCzLeaIAynuOvc26CO8HmUsQXE7+Qz
X-Received: by 2002:a50:cb4a:: with SMTP id h10mr450314edi.134.1554310371329;
        Wed, 03 Apr 2019 09:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554310371; cv=none;
        d=google.com; s=arc-20160816;
        b=hQ36SfXiovAhbmADHnHnFX2zzRBp7lsJ8JOAWs6CB9e6k20OTYw84BlSE4+LVvt5oW
         7V+8LFlMsur1i9oPjYDVpxcECKMwopPrZ1JNDNNN2KbvefkAO3+jiC7BSBnU2bwCJrm9
         HpculCx2yb3eZ7DO0px/OLv8DeORX4HKQ7Ic7yGVB01YVAnMc9RovTKkNnSPPtJtAt6K
         uIzloIodCSKq5rmJ4KVp4aPPb0cw9sqSkpWi4WB1M4nsEl8Zkmw4k5NX7aSw3kBvKyvO
         PO8ThqJaGT5johbYt40MhXyFJQjLXbWonLXvM+7nDzV6FftUGMG+eVXTJe5f7JmyYSN2
         LgEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iGxxtIVqEzp1RVOI6u7Mj+o50/tLE0xJ0apojvzIrxc=;
        b=J7MejvPw8/UFAx8/ChCWocJ/oTo0xwYM0S30+cprIRR/t4J6fGoagzpqD+d6zugVxc
         9t3957tzUoWgCQJ3NvEjMlXGeE+Pfg/dpWIgdadurD0EJs07Haq2cd87pWMLXqxCpT9p
         sTvkWjDRePphgkwU8IwpfBXRVNPKv8SSTjMxHmoHBV9KLUNUZen6agC6ufxBPznWijoD
         kg3z9vel0OI9vWf7DzAaJg/x7M6Dlqkjwzd53sIy4PMMdeluRzN8nnle4Zn2HCYAQ5px
         /Y7B6unpvqaFONzuP/NSzgSDcTCl1a+QoBHVNolEAVcaH9MKB27JCx39YxSbJK4PUqn9
         2pjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eMKx8OvZ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m90si7349475ede.277.2019.04.03.09.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 09:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eMKx8OvZ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33Ghk6g131470;
	Wed, 3 Apr 2019 16:52:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=iGxxtIVqEzp1RVOI6u7Mj+o50/tLE0xJ0apojvzIrxc=;
 b=eMKx8OvZ6FoDYDKsbasn8MIS6dsh0biicj8fxmGWOf8mjW29OUno93FDZ+rwFoQ85kYt
 T/w9UyqLWqtHrhEhQ1YaB1x0M4THLsgjrYQYKu3hxaBpDSXmilQ9jphwop3MwmoeEu/L
 rC5FLKD33mFhSnenXyKKUUiyDizZOeTD9lkgtKHC3kQJewpFfzX30mP1u3tJ9tbdJkEq
 wtKkTB0L4y1OdbAyedKLuGO/ltNYiHEPNgQF1kXtWt94CUFtzgQtRVhNTqxnDmE3EP86
 7YuQtJEC/ZNWVS+2eBwZ2vAUB9yB1AhAbxmkfPuTXEkmQA2yyvagoaSwygzGz0FLI1UX NQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rhyvtaa5s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:52:41 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33GqBLc168298;
	Wed, 3 Apr 2019 16:52:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2rm8f579tn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:52:41 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33GqcFo004355;
	Wed, 3 Apr 2019 16:52:38 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 09:52:37 -0700
Date: Wed, 3 Apr 2019 12:52:57 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Steven Sistare <steven.sistare@oracle.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        linux_lkml_grp@oracle.com, Alan Tull <atull@kernel.org>,
        Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/6] convert locked_vm from unsigned long to atomic64_t
Message-ID: <20190403165257.prekuppqbcempuxo@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <abe31bae-1bdf-b763-c4d1-5e4ea2ccda13@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <abe31bae-1bdf-b763-c4d1-5e4ea2ccda13@oracle.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030114
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 08:51:13AM -0400, Steven Sistare wrote:
> On 4/2/2019 4:41 PM, Daniel Jordan wrote:
> > [1] https://lore.kernel.org/linux-mm/20190211224437.25267-1-daniel.m.jordan@oracle.com/
> 
>   You could clean all 6 patches up nicely with a common subroutine that
> increases locked_vm subject to the rlimit.  Pass a bool arg that is true if
> the  limit should be enforced, !dma->lock_cap for one call site, and
> !capable(CAP_IPC_LOCK) for the rest.  Push the warnings and debug statements
> to the subroutine as well.  One patch could refactor, and a second could
> change the locking method.

Yes, I tried writing, but didn't end up including, such a subroutine for [1].
The devil was in the details, but with the cmpxchg business, it's more
worthwhile to iron all those out.  I'll give it a try.

