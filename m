Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15EAFC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:25:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3B5274BA
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:25:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2LE6GvdF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3B5274BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 396A16B026D; Mon,  3 Jun 2019 13:25:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 347BF6B026E; Mon,  3 Jun 2019 13:25:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20EE16B0271; Mon,  3 Jun 2019 13:25:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id F265A6B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:25:12 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m1so14435546iop.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:25:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oT/Qbn3UCsmi4yHa5dCSEdLGPezhKqW3sHyFd1k2UMQ=;
        b=OY6GEPJNkeuG2tbKyJEmWEKv+guztdTyyaUpeaDsMbknpNIfvLV+3S6m4oQJmyI2c4
         rcNa+aD8tm8z8lYYl0102+qBADgR+DHtbvE98eiKaBw5wWslRUxiRwb+VAA6bd3hz0du
         JPMlaT7I2dHwAt9zX37YwXyIyYBejhgtb47jtcyzsH6qFKYm6OSfkUAhxvB4PEz/hoKY
         UYoQnlz0A4pz3UhBruEsbtIyrsEPKUVBzsjNHZlTYvuEJvplzjx/z1+2kKBspBF5d+1N
         hvhOxteipJ/jgBhan4ahp9wBthZBarNqm+dnb6esP0jcoWvnv86ATEwbwsvaZtF3twvH
         JtCA==
X-Gm-Message-State: APjAAAXEtIACb8AzUB3UtWfLimHAk6zJeLhF2q5GxK0x5gaxY5EGHD5N
	v2A83kd/lEjkQ/JgcPmacW9DUIIybWz5xQ8RlnzIILCS/aM4gLHHzeoPeWNL/iYcQRrZuSqrDn4
	pA2PX+7RQjzMElOkpjL5lOoNtpSWAoNY9BRN1OiRHBq2qFdd2vVY9yw0/nOdcECypDg==
X-Received: by 2002:a5d:9812:: with SMTP id a18mr4106811iol.289.1559582712700;
        Mon, 03 Jun 2019 10:25:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOswr+WhFwT15bgHATrXnZCjQWlsnQWf+lo9suKiBH5ttEvglAp7WHpXXscsoCuqpsCinW
X-Received: by 2002:a5d:9812:: with SMTP id a18mr4106767iol.289.1559582711910;
        Mon, 03 Jun 2019 10:25:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559582711; cv=none;
        d=google.com; s=arc-20160816;
        b=CAwuGHWekJb3WPP7M+tfNyV1yU+bXRMQjAnVrzQpprj/26BHCNhlEB1UZD+mX1AzSb
         bqHTYUgLFWe6iimGKo6BdCt7I9Qth3Hu0x3isnux/5ekXmxSwEqdF9YM4v4LqI1u0gaq
         dJXooFrxtEkgwcR5dC2fgpEdlwAcesNo6iix8O6WvZPDexha7qjL/ErOQzqvUHTdf1w2
         S5FtELMGC5Oxo4jN8UMJ66NXzuCLUGDVHATLpMy+OGzSRYMtRwDT/b+G1GHEUxbo15q4
         ViLaRSnWlfDaFZpDjeBBbC81gOJdjPJhuu8qYwCtthbeaO5Lb5qts/nMBPrKvQ6Ri49h
         Wt/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=oT/Qbn3UCsmi4yHa5dCSEdLGPezhKqW3sHyFd1k2UMQ=;
        b=ye2ZKmHNZRvb8fTuai0inwOWtK+ad/ZfOeWz2q306n0OtKcSN1avpugKbSPooJdy9i
         aE8TKEUYZGW8VKS/vxPUscez6J0xWpgNIcG9n3H1fAMhQdekOxMqDeztHU/v/w4ihcnQ
         SZMSXM1zsoN94TM82Tt4AVkkYgHrIjs3Iu0S05ufXPdn/ZyBwkoOjGPE++rL4VavuuKL
         v7hCGbsoWEcoTOsevMK+v92BSyouK8d8nI5bJupgSnEzE4JseRUOqIXE/HyZqNTcWflR
         999vpwQ5cAnI4EBWhfIhKzM4nXVkiEpoCXlVgkAOZpi0PPzLrRLDo1I9zF3oaSQqFRLH
         6A1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2LE6GvdF;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b5si9304419iok.70.2019.06.03.10.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:25:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2LE6GvdF;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53HJ84U105594;
	Mon, 3 Jun 2019 17:24:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=oT/Qbn3UCsmi4yHa5dCSEdLGPezhKqW3sHyFd1k2UMQ=;
 b=2LE6GvdF1Spn4zQDJ/S+Y7Lhctbk5tePOYyaCmnqsyOr3uLvhrds+WPbVc6hPXAu9sIP
 B0Y1nU/oFPg6ixsYXCZSDZnvxtWWQNi0j+MRjf0CBoAknHC52G/m4p1P8MrAI990VZia
 8ujGe7kWSRf7xAIGevSgKmBC3Wct5lXwvZ7qokhMwnYkhd63Cundz/Zl5pnAreMOjiWl
 HWG+ViIH0FjQ4gxddvAi59ghuxHj+MdKKsrJR6n36wSKJyN/Ok8+n4Cy2uvBvd+9a3r5
 V3Zqu7KeEDVK/adkgGrKlbvS/ddKrXPyTWM+bUnf/xQW/+CSelKEJwh4J3SpjWi5HA+8 Jg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sugst8dvs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 17:24:42 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53HO5Kt055049;
	Mon, 3 Jun 2019 17:24:42 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2supp77yt1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 17:24:42 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x53HOdQw028642;
	Mon, 3 Jun 2019 17:24:39 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 03 Jun 2019 10:24:38 -0700
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for other
 arches
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>,
        Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
 <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com>
 <CAAeHK+xX2538e674Pz25unkdFPCO_SH0pFwFu=8+DS7RzfYnLQ@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <f6711d31-e52c-473a-d7ad-b2d63131d7a5@oracle.com>
Date: Mon, 3 Jun 2019 11:24:35 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xX2538e674Pz25unkdFPCO_SH0pFwFu=8+DS7RzfYnLQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=800
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906030120
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=813 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906030120
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 11:06 AM, Andrey Konovalov wrote:
> On Mon, Jun 3, 2019 at 7:04 PM Khalid Aziz <khalid.aziz@oracle.com> wro=
te:
>> Andrey,
>>
>> This patch has now become part of the other patch series Chris Hellwig=

>> has sent out -
>> <https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. Can=

>> you coordinate with that patch series?
>=20
> Hi!
>=20
> Yes, I've seen it. How should I coordinate? Rebase this series on top
> of that one?

That would be one way to do it. Better yet, separate this patch from
both patch series, make it standalone and then rebase the two patch
series on top of it.

--
Khalid

