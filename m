Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D117C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:20:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07D28222DA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:20:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1Q3h77ek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07D28222DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CA88E0002; Thu, 14 Feb 2019 12:20:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84C778E0001; Thu, 14 Feb 2019 12:20:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739F68E0002; Thu, 14 Feb 2019 12:20:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2278E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:20:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a11so5670611qkk.10
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:20:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=Z/qAl0rILNkjo+9n96+ul65QbUgdUPpDBNBiImZV1P4=;
        b=iLg9EqpL5M8DRFBByqHSdTxeLqNzZ6bz3+SIFYJTWwGQTkbCG84A0i1or337QPkgsp
         DXbzEuMD/4g9ErAUribolGBjF/XafNJ6m6FuQQoeNqX6F+mZe0jGHTF8umHlQWzX4rF/
         jsdbNykGLogSXt54AYw9jjXaBojvZeyDSvGbSvfFfa2eaxLxsWMfYXC989VPvqRdFCL7
         gMk1cnWofwfosf1dPa48+scfy/QgiBdGt5yeSE6ju7siB4NYxqSaruR79l95QkxkhyQY
         qRJa6VaJP6NXY8N/OKifTK9ztZbHPmUM/56c+F5NkadjdHouvY+Vg/i2VRKRtCa3NX9/
         g2sw==
X-Gm-Message-State: AHQUAuYDc568kSJxaF1q4uYHhz45F+teK0N4LmJi7inilKkp1OzPv8dT
	GJOL5pbMXRXA0nvQiSvS+1ogESBF4Ysqhu9E1gdrXgmX1jOb739+6VDjx7RaNgZK6zutXQXJLQF
	+cNF09+bKmIaHJzio6O+64GwTyOplCvophe83XFPmqgWyAYeOE9iO8xBMpATWI7p8mQ==
X-Received: by 2002:a0c:8b50:: with SMTP id d16mr1204217qvc.233.1550164800056;
        Thu, 14 Feb 2019 09:20:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibe44jAxMt+xvZ/BYk3y63HDkiy5wm97LNQK7dRSvL6uu2N/do2XQ2z9CC5v7sVYInY+hU5
X-Received: by 2002:a0c:8b50:: with SMTP id d16mr1204174qvc.233.1550164799570;
        Thu, 14 Feb 2019 09:19:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164799; cv=none;
        d=google.com; s=arc-20160816;
        b=cCl+itxXxXfE+ghIMnmSy/4tRAZRmEPHxliHFINb6/Ky2TNzUxP5Njsae8pUAxMZEC
         68gIfIpSsgF2eA2wefO/S3IYf3EGEzau+fTMxpVFlOLUxB4iRGhAGd6C3UjyEJBoMPTm
         zsAG4IiIvbK73jgRG4D0rU+UUNXEISbP52gHSyZCtjVwHvUsER3izmipB11Pw+23xFzk
         PG2ljrYR4c4LE/Tq6HCqAJgS7p6Yk6GvVJYlNpZf+PvhbuGqqAOEBtl0TPidkVJ58Oc6
         efLSJczUK8UqgWfvx+CTCzAJ8h2HBnEKhM64R6nIsvbqnSzdp1Pxy4gONN2DSxcq1Q67
         hqlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=Z/qAl0rILNkjo+9n96+ul65QbUgdUPpDBNBiImZV1P4=;
        b=fEaMa+O89zpC273sr5iHq5xsSac1SKg1M9WgmXErGew3UZgNjsdoqNAxN9u0ElZ9gL
         TceSiKdcD2pxIdVl03nrqRMndU2oDzro9x+lIh4AUdzdqBmn5SileLJ6gDe+f9MSw4/K
         ++NWMJOPVvgPEbxqj0+Cxyq2gmZjg/tDsIeDG4P9ZC2YuOBrwInyQOVKRusxyyyWOgTr
         UpFcdlBR6skG6fJGF+8C+8Z5DYpyLWdpC6XBIXeMCZLprUpNcErL8nbVs+LeQESgDEdt
         7g0a5jrsoD+n912RUlac+Y3IjcupwIJVt3vHSzSiLthXw6Hg9zBDD5V0aLDYByYgYzR2
         A3WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1Q3h77ek;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u2si1946477qka.125.2019.02.14.09.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:19:59 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1Q3h77ek;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EHEh9O126979;
	Thu, 14 Feb 2019 17:19:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=Z/qAl0rILNkjo+9n96+ul65QbUgdUPpDBNBiImZV1P4=;
 b=1Q3h77ek/zcGl7JP4I1iF7b4Hd/BiLn5LlRyb46NoP9p/3eNXUtoIXxQ0usjbmwA/eKV
 4lbXkmHLYKUrS6lMKRlRXS5f5lbIoJwThJXYI73oU1OPchgUDeibud+cHIokXFU6JrlW
 ZGIvam5pTDfWLBEUl2fuxtP3QP8lKW2unELvZ6gVTZWYrCuDReVvdWoOFiK45WABD8yV
 Er90dBqJdIOtKiH9ONgPnGbS18o3KWHnElNE2wFCcLjenypobwery40aQmsh2mklGa+f
 xoc4FdeJyPR0nuWtHgQomJC2wO859Y+gYZD+4wOMtYGER4l+mYbIne5K3+CHeHt6qaPi og== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qhreksbbt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:19:28 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EHJRxJ005673
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:19:27 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EHJRWM021695;
	Thu, 14 Feb 2019 17:19:27 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 17:19:26 +0000
Subject: Re: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page
 Frame Ownership (XPFO)
To: Borislav Petkov <bp@alien8.de>, juergh@gmail.com
Cc: Peter Zijlstra <peterz@infradead.org>, tycho@tycho.ws, jsteckli@amazon.de,
        ak@linux.intel.com, torvalds@linux-foundation.org,
        liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
        mhocko@suse.com, catalin.marinas@arm.com, will.deacon@arm.com,
        jmorris@namei.org, konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Marco Benatto <marco.antonio.780@gmail.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
 <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
 <20190214161552.GF4423@zn.tnic>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <6c689028-6748-66b9-0d9c-2b57b5dd6383@oracle.com>
Date: Thu, 14 Feb 2019 10:19:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214161552.GF4423@zn.tnic>
Content-Type: multipart/mixed;
 boundary="------------8D637083EDAD02B721201657"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8D637083EDAD02B721201657
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 2/14/19 9:15 AM, Borislav Petkov wrote:
> On Thu, Feb 14, 2019 at 11:56:31AM +0100, Peter Zijlstra wrote:
>>> +EXPORT_SYMBOL(xpfo_kunmap);
>>
>> And these here things are most definitely not IRQ-safe.
>=20
> Should also be EXPORT_SYMBOL_GPL.
>=20

Agreed. On the other hand, is there even a need to export this? It
should only be called from kunmap() or kunmap_atomic() and not from any
module directly. Same for xpfo_kmap.

Thanks,
Khalid

--------------8D637083EDAD02B721201657
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------8D637083EDAD02B721201657--

