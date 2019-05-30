Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 071C2C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A667F25D58
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:06:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AwmlutIR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A667F25D58
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E8DF6B0272; Thu, 30 May 2019 12:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39A516B0273; Thu, 30 May 2019 12:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23C4E6B0274; Thu, 30 May 2019 12:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0105E6B0272
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:06:36 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v191so5887719ywc.11
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:06:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+GLA6qLrn26KPJEpEajh3ipF/BPoxxfouik/rd34OzM=;
        b=H0y7A9XMWKtkDil7bN/+A41MUhUQ7KhLHJjR453aqYDUE+6q60Yq880X//PVKcB28T
         WF/S5GlvKx1SGop8uvBPfar0PKBtI8/6O2iNL3Pal/GNaoQa8JoGmB20vwXGFGa6b+l7
         b0ZI0V8yFVuIFwf+F5KTlwvXlbAczti6NywaF+sKozLx8GuO5xjdivXj4hDKVwf4gRvs
         cKbm9GPev1R5Y3zu7vYUCIv26EJR3Jw9NIaibK9+gBHxXOO0zh5bR15GeHWtR9HHKVY1
         tpZnLWwxk1hIL6PXlcyFGxychRoDghuVCdJ4zm+S7FJ1/sN5/2bIlUHr4B5ZhKTFumVO
         ioGQ==
X-Gm-Message-State: APjAAAV3YmhS6l4rTJ1XlOtMwLQvkDWE+znQZabD6y5d32rKPN2rJgHj
	itmf/Ngrsic7mizVL2eZUvLRe05Mod4U52SPn/7VKXCHxd5ZawlosDuWceQSKoCq8vOY4o0320d
	cPuXTB/9yh8AfSZ69zP0fJZojDt+nX4lTbgE0l816CtqCr1hfr2Oo9LbgS4YDcrkQTQ==
X-Received: by 2002:a25:504b:: with SMTP id e72mr2129029ybb.146.1559232395718;
        Thu, 30 May 2019 09:06:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygTSb0ZSZ01gF9FZX0hHhHN9sDIX1rQC0qWoIPNcwJWosg+oE+KmXy1JjWizMs49pSepcs
X-Received: by 2002:a25:504b:: with SMTP id e72mr2128951ybb.146.1559232394502;
        Thu, 30 May 2019 09:06:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559232394; cv=none;
        d=google.com; s=arc-20160816;
        b=IudWAQyDspv9mbM3XglwgDMwttTv8J5w82dKmZW5gOIIwIa2VF0E5c1u77FpeDzix4
         yzVymHxFpya4yovWhpr4w0LFoLnLmwUt/M7pvC/5nkUBNAPPRr2MjuR99o9svmJMy5zT
         LD/het+QvM9ZNwdHYr09t5EayqNFM2KEnlm/IS5DNi48YZAsEZezzr7AohscYFqepvb/
         pDhiPRNpkyM7W4M97BWgEjnHTync52LUh8iQLEKWRX2GSR1Kd7UwnQLS3ganAfwOygc7
         krnK103TMnxBsV+J1DgAB3Ocg4Nbc4TASIuelELlav8NcQXpJRJMdzrrBn4zY+YUbuXT
         xuIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=+GLA6qLrn26KPJEpEajh3ipF/BPoxxfouik/rd34OzM=;
        b=t21QzK2s8kLERDDhjWtiDtQiJbC+XuDma0pnj/rl48Bre7AkhBYNgZ3mpQJi9Aa2M5
         bNNrjdvBVziupLUv6t/fpjAE39Gi5Cgjr1XS4lHRhtksscDmCZRPdcMF/36X8zpba566
         3T+ch3eIG39p0a58uGULO+RiWNAFFi/irNI4LRR5UanTZs3U5KNLuwr8yCcu5eVL5cAj
         rDCTJTKg+tXoiqRcabjUcGPT12kvkYA/SSWStm3fh8SGiucbOelFkoPaqFry3lxjB3tO
         EnkWvind7raAMNmAsKmDl8HHWQBvIPkRCvgHUXyIIb0sEoM3seWDXoksAlvg5EWAJuHW
         x4aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=AwmlutIR;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f138si1099746ywb.69.2019.05.30.09.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 09:06:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=AwmlutIR;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UG4VBr062702;
	Thu, 30 May 2019 16:06:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=+GLA6qLrn26KPJEpEajh3ipF/BPoxxfouik/rd34OzM=;
 b=AwmlutIReVoUCST+0CvuT1i683wuk/bgaVaXpwFLuLObOH6WAfasg+1gIzeRdE2lXYjb
 k8P67eGtLM2jUaKR9Cy3m4TvgSb5+cBwa2T8P+yN1HdMoZWh+Ggt2lVsYNq8wgS4RczC
 Ob71kUfljvyH5fcGoqQaqFQS4TYWXfMx3pY3C+r2yQF46AIqpx1jAW7P3kPlizYiO3T0
 ZblzYxr+PrepeLcYjU1orVLKF6nQOQcaFQBGNaPWrM8vzs9svllGt0RN7sK/lmLWd9+b
 VLJpczb5tPtPCsmplNczUgngjT1jT/8Yk0IfRgeZkTSIRA/aLnoWnZFsdY3idrib592i Ow== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2spw4ts5tq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 16:06:12 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UG64iQ193779;
	Thu, 30 May 2019 16:06:12 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2sr31vy3va-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 16:06:12 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4UG62SZ026718;
	Thu, 30 May 2019 16:06:02 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 30 May 2019 09:06:02 -0700
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Murray <andrew.murray@arm.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Mark Rutland
 <mark.rutland@arm.com>, kvm@vger.kernel.org,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
        Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
        linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
        amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Kees Cook <keescook@chromium.org>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        Kostya Serebryany <kcc@google.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Lee Smith <Lee.Smith@arm.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Robin Murphy <robin.murphy@arm.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <11193998209cc6ff34e7d704f081206b8787b174.camel@oracle.com>
 <20190529142008.5quqv3wskmpwdfbu@mbp>
 <b2753e81-7b57-481f-0095-3c6fecb1a74c@oracle.com>
 <20190530151105.GA35418@arrakis.emea.arm.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <f79336b5-46b4-39c0-b754-23366207e32d@oracle.com>
Date: Thu, 30 May 2019 10:05:55 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190530151105.GA35418@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=660
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905300114
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=684 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905300114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 9:11 AM, Catalin Marinas wrote:
> On Wed, May 29, 2019 at 01:16:37PM -0600, Khalid Aziz wrote:
>> mmap() can return the same tagged address but I am uneasy about kernel=

>> pre-coloring the pages. Database can mmap 100's of GB of memory. That =
is
>> lot of work being offloaded to the kernel to pre-color the page even i=
f
>> done in batches as pages are faulted in.
>=20
> For anonymous mmap() for example, the kernel would have to zero the
> faulted in pages anyway. We can handle the colouring at the same time i=
n
> clear_user_page() (as I said below, we have to clear the colour anyway
> from previous uses, so it's simply extending this to support something
> other than tag/colour 0 by default with no additional overhead).
>=20

On sparc M7, clear_user_page() ends up in M7clear_user_page defined in
arch/sparc/lib/M7memset.S. M7 code use Block Init Store (BIS) to clear
the page. BIS on M7 clears the memory tags as well and no separate
instructions are needed to clear the tags. As a result when kernel
clears a page before returning it to user, the page is not only zeroed
out, its tags are also cleared to 0.

>>> Since we already need such loop in the kernel, we might as well allow=

>>> user space to require a certain colour. This comes in handy for large=

>>> malloc() and another advantage is that the C library won't be stuck
>>> trying to paint the whole range (think GB).
>>
>> If kernel is going to pre-color all pages in a vma, we will need to
>> store the default tag in the vma. It will add more time to page fault
>> handling code. On sparc M7, kernel will need to execute additional 128=

>> stxa instructions to set the tags on a normal page.
>=20
> As I said, since the user can retrieve an old colour using ldxa, the
> kernel should perform this operation anyway on any newly allocated page=

> (unless you clear the existing colour on page freeing).>

Tags are not cleared on sparc on freeing. They get cleared when the page
is allocated again.

>>>> We can try to store tags for an entire region in vma but that is
>>>> expensive, plus on sparc tags are set in userspace with no
>>>> participation from kernel and now we need a way for userspace to
>>>> communicate the tags to kernel.
>>>
>>> We can't support finer granularity through the mmap() syscall and, as=

>>> you said, the vma is not the right thing to store the individual tags=
=2E
>>> With the above extension to mmap(), we'd have to store a colour per v=
ma
>>> and prevent merging if different colours (we could as well use the
>>> pkeys mechanism we already have in the kernel but use a colour per vm=
a
>>> instead of a key).
>>
>> Since tags can change on any part of mmap region on sparc at any time
>> without kernel being involved, I am not sure I see much reason for
>> kernel to enforce any tag related restrictions.
>=20
> It's not enforcing a tag, more like the default colour for a faulted in=

> page. Anyway, if sparc is going with default 0/untagged, that's fine as=

> well. We may add this mmap() option to arm64 only.
>=20
>>>> From sparc point of view, making kernel responsible for assigning ta=
gs
>>>> to a page on page fault is full of pitfalls.
>>>
>>> This could be just some arm64-specific but if you plan to deploy it m=
ore
>>> generically for sparc (at the C library level), you may find this
>>> useful.
>>
>> Common semantics from app developer point of view will be very useful =
to
>> maintain. If arm64 says mmap with MAP_FIXED and a tagged address will
>> return a pre-colored page, I would rather have it be the same on any
>> architecture. Is there a use case that justifies kernel doing this ext=
ra
>> work?
>=20
> So if a database program is doing an anonymous mmap(PROT_TBI) of 100GB,=

> IIUC for sparc the faulted-in pages will have random colours (on 64-byt=
e
> granularity). Ignoring the information leak from prior uses of such
> pages, it would be the responsibility of the db program to issue the
> stxa. On arm64, since we also want to do this via malloc(), any large
> allocation would require all pages to be faulted in so that malloc() ca=
n
> set the write colour before being handed over to the user. That's what
> we want to avoid and the user is free to repaint the memory as it likes=
=2E
>=20

On sparc, any newly allocated page is cleared along with any old tags on
it. Since clearing tag happens automatically when page is cleared on
sparc, clear_user_page() will need to execute additional stxa
instructions to set a new tag. It is doable. In a way it is done already
if page is being pre-colored with tag 0 always ;) Where would the
pre-defined tag be stored - as part of address stored in vm_start or a
new field in vm_area_struct?

--
Khalid

