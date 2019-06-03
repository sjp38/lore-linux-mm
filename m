Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48F20C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0184324698
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:18:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="05U6KHBi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0184324698
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 802BA6B0269; Mon,  3 Jun 2019 14:18:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B3326B026B; Mon,  3 Jun 2019 14:18:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 655656B026C; Mon,  3 Jun 2019 14:18:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 397C36B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 14:18:14 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d62so9330214otb.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 11:18:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GlaYcvRbXVbYyKKXSyNwJ8tBGJAG2pfqt1R7amaBqEw=;
        b=CRjBOw70Ege8uPw9vXe+xZWlG9NiSW3OCKLnpiloZ66KpMc8mRG4XHuOF9gXPkOqg0
         4KWD1I1274nNWYRdhC369UDhtZPK5NsXeh/F+K/7mi7nqmbTKXUy65z2DatTrC2y7hfC
         TF87lYCGDajNQh+Ei69PpqMNPGZVLcudaLqt76FtkvT5txlgNA5c3LeoNvPqNUe0VU/r
         gFcK8Wooay+VqsV65TfLC5Xl3qeD6OoGDBDetOFrx2K4uuuxgziNKxMYDrMAGkysncZ8
         6UIFv9p9iFZzXPXij4A3HoPXbfssgsCYIETA80rG7eqaVVEBFl95mw0C3hrcrfVOQyIm
         Pdrw==
X-Gm-Message-State: APjAAAVMUM6OycWU9bOUbAzYbqt8p1b1Sga+pI8hqIOUIOSBO1dnxumK
	W2tV4yoVPNWrFjAEXlvJpylfz8qcBs2YwS2JIfVOLGgGzVyDdB69tWUt+x3BOnawOV1slmvTLko
	Ye1nc+I8LQ5bPo7ZrUqFx2YGfCqBuKvTM5suWAL4z9xXYFX7+tTRWvzFwfu0M6XwYGA==
X-Received: by 2002:aca:d98a:: with SMTP id q132mr1853328oig.133.1559585893895;
        Mon, 03 Jun 2019 11:18:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxm5lbFlNvc502nLJoBuVZBnSG0p0PpAG69j6c8OUxminAOxdbFMzZ2K3sDyzTxjU0IrBc7
X-Received: by 2002:aca:d98a:: with SMTP id q132mr1853294oig.133.1559585893112;
        Mon, 03 Jun 2019 11:18:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559585893; cv=none;
        d=google.com; s=arc-20160816;
        b=JCTWIX67mRlJDXxLsErmeZXOdWuFJO29RSLGgG1MV3nTluDh9P1LALjplXvLq7FThv
         6LwWHRTEF7ylLaHAd5FdEKxYZ42QC19n2Jo0wVxatXVp6k6aO2lgpZgcmhgkyyaWuuMN
         iFmWNAw8yeVl0lI1mXuDAyBcJxBUIapGVkOaDbjn22zvmVg2hqO7xZKjgZ9iNTFy1jJN
         2X7HcposWcavIto95iuaqlJhdIeGOmQXiRoSHekBomJlq3A94n4XRCzDkphFW957EthA
         lfIGSc6y0cSe738L0gnjYrEMYBMxpfrtrRysmBUTpWdHS4789qAlTDmRmruvjfzzFSuy
         BfZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=GlaYcvRbXVbYyKKXSyNwJ8tBGJAG2pfqt1R7amaBqEw=;
        b=lO135YRW/djuE+eYDpzu2ZNweyklOeteqtrNr2K8nW3aSmMxhe17Cpqc8nE8LMp9cN
         7yCd2vPYh2HFEVhSJI1JF09gliUCSlGSHrfAp7qVVh3Xg9PsqLyVKohgJWzqjBvFsikB
         EHOX3iiTIjjFBWH2RKL/MLlPSDXSooSS6J/XCcEDTTPOTWYFmQnPKkcTdZbsiGrgmx8g
         g4UENTbpP8FXXK3hjc27t3aUpcGA5rR9K9gvcYR9jpE2KyiMk28JemuazBK5vqNJo2Zy
         yOsAQJf1jKDLw4kk5aQLezisCfHaZfbTJQbnAjp7t9yHIFN8KRoMdvGfocFgHYVANclJ
         Mzxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=05U6KHBi;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i82si7322431oih.93.2019.06.03.11.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 11:18:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=05U6KHBi;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53I8gIs153035;
	Mon, 3 Jun 2019 18:17:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GlaYcvRbXVbYyKKXSyNwJ8tBGJAG2pfqt1R7amaBqEw=;
 b=05U6KHBi25HCGJeXlllc8lO/7iSw1O36+nkjRk4VyMlhqURaxhzyWEAG56qBArt4ZIXH
 Rs6H67bbFeXkJ8dNAj/863iIftETrMYapMu/08uwIeo59ZY37LjyfUDhTwYxIuq0apcm
 mxgbgRIkv1jIFr3D9wbmIYjjONDeqSnJ2Q6OpAFTFQJnXlxeGQP3CRq4pVItc3hsAHhY
 eyf+kruVixj7mGRtSpX0nUteC3Br6Cqgqf9GkrLjvi8wjVLQ+WKBafILZOHfOiiQNyNp
 J0U+PSjroYIWCro+VOsKn1DLmMtnqiEQYZkolve4C6NI/cUHUIedA0+lH2Bzv9u6n/N0 Yw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2suj0q8ka1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 18:17:43 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x53IGZGQ023818;
	Mon, 3 Jun 2019 18:17:42 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2sv36sc445-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 03 Jun 2019 18:17:42 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x53IHbbL010166;
	Mon, 3 Jun 2019 18:17:37 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 03 Jun 2019 11:17:36 -0700
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for other
 arches
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
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
        Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
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
 <f6711d31-e52c-473a-d7ad-b2d63131d7a5@oracle.com>
 <20190603172916.GA5390@infradead.org>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <7a687a26-fc3e-2caa-1d6a-464f1f7e684c@oracle.com>
Date: Mon, 3 Jun 2019 12:17:33 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603172916.GA5390@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=970
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906030124
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9277 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=988 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906030124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 11:29 AM, Christoph Hellwig wrote:
> On Mon, Jun 03, 2019 at 11:24:35AM -0600, Khalid Aziz wrote:
>> On 6/3/19 11:06 AM, Andrey Konovalov wrote:
>>> On Mon, Jun 3, 2019 at 7:04 PM Khalid Aziz <khalid.aziz@oracle.com> w=
rote:
>>>> Andrey,
>>>>
>>>> This patch has now become part of the other patch series Chris Hellw=
ig
>>>> has sent out -
>>>> <https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. C=
an
>>>> you coordinate with that patch series?
>>>
>>> Hi!
>>>
>>> Yes, I've seen it. How should I coordinate? Rebase this series on top=

>>> of that one?
>>
>> That would be one way to do it. Better yet, separate this patch from
>> both patch series, make it standalone and then rebase the two patch
>> series on top of it.
>=20
> I think easiest would be to just ask Linus if he could make an exceptio=
n
> and include this trivial prep patch in 5.2-rc.
>=20

Andrey,

Would you mind updating the commit log to make it not arm64 specific and
sending this patch out by itself. We can then ask Linus if he can
include just this patch in the next rc.

Thanks,
Khalid

