Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 239F9C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C992021479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:35:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ylFkenx2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C992021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D0656B0005; Thu, 18 Apr 2019 10:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6808E6B0006; Thu, 18 Apr 2019 10:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FD5C6B0007; Thu, 18 Apr 2019 10:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 136146B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:35:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so1474460pgs.4
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AL/6XEs1B3BsG/bXzvFYIzuqptan4i6pMcE1H0+0SkI=;
        b=bvKyAzy3+PISw1zyIK1u23Jlcem0GxxvyVi4kB+UMv8Cr+9+yubEKjuf1jT47ihXpu
         JHjyFqMnpazyUkdodNjvJWCy0qTxjJRgdiLu63ZZq2yhUQFSPZlHSp7dcIqZFDqUU9Pw
         5Xbc3XEJAwe/ansevafPKAJ48i14AXjGXthx8EuMkw1QR78VzYN6Tczg/ddjScbSCbGi
         c8jJTVqVwd+RC9nmMsjkY+jsnQZT8vHN5LVl7uq7x5CuOtuN9imEhdj693vIWVc1pka8
         bnLVQE6/ZCHOHOsG0Crx1XwRwP8LVa7OsNaslRC4knX4S5uvJoGa4YHPZ/oY7iKmCOz+
         Rtxw==
X-Gm-Message-State: APjAAAVj/RxB5uO3THqOEmM2iUQYtdOrzvfHcH2p9U2hAlnz7B+ZYSjQ
	pVs06rxdb5DKhzHqlVEJkza8TnVAyXPwEm+bTb0quP3lsneQBqmaWHfVdnutfLbqeZu/6MVyFq/
	0vQ7p1JO2YsTMhP9pmRnp3aAEiE9gUGEegg7yC4dQfGL5lT7LY6AHa0NJGx82ndt8lQ==
X-Received: by 2002:a17:902:e683:: with SMTP id cn3mr94840140plb.115.1555598128423;
        Thu, 18 Apr 2019 07:35:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0rGZgYZMmC2oQLTb5nY+PTo/Hx1Fd95EO6lKR9ZnjG7pL0yA7vVYplva71d1J7nJr/eBZ
X-Received: by 2002:a17:902:e683:: with SMTP id cn3mr94839961plb.115.1555598126641;
        Thu, 18 Apr 2019 07:35:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555598126; cv=none;
        d=google.com; s=arc-20160816;
        b=A6YOWjnoJ0MCUHcRWc72V9tvRyW3EWrJ2SuVGZC3DKBQiLMPgPkTGc0kNjEgyL688h
         rbX6trt2lNYvQSVClXzskrDSUwz2Jj7U0VryPMHxLwFPhLGYDGYj2ONl/l8oLnCsXP+x
         Ozhs0x5PDKMPSDrLRVbihfXf0p9ewibCiI9VWKJJBNoYmbiOoMB7D3QQgkAhvSK2aI2P
         aud+7xdWkG2F9poXlco1Ref70TzzVNWd+YgX00SVtWh8Zlz5ZcIHv79NZXGXkYrjq1BI
         n0pwgLBtj7silFK024296t6KYUK4jDeu73I3hAkC2w2u3yl+t7X8QXP7IheBd+829cnu
         L+SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=AL/6XEs1B3BsG/bXzvFYIzuqptan4i6pMcE1H0+0SkI=;
        b=SVJ39W5ScaATXusbWq8i8IXTFR1laaNOQSUNG91GLJpP+DSjvgc+zFVdQt1zSl5S5z
         9E3NieuZFkaFFByHwbgcMb2pnDhS3M9Qsd5xuWb+wGFhm1oAJoxy6sKBiV22a0eOEO6z
         Hey3on5vgLk38UWDEsRFEt3VOf26QJQ8sxa0+VLKrfbKm2d4lKBTRBzp2FV2ve9Ob9A1
         4vcw1/m4IVi+YrLMkWjkVZGrcJxQb2Db2OPqvyQgapKiNqlJUB1Y7qDY6GmfRvSdJw99
         TOrKt0SzyoyZuJIH+3C0EjQrUnIEFVMzGY8AbNZV2CK8cSqzasTz1I3GWeYbwBAFicRu
         JtaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ylFkenx2;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l191si2035460pgd.549.2019.04.18.07.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:35:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ylFkenx2;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3IEJJ4K081960;
	Thu, 18 Apr 2019 14:34:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=AL/6XEs1B3BsG/bXzvFYIzuqptan4i6pMcE1H0+0SkI=;
 b=ylFkenx2gLgBHYyGmWupVhKcQN67lFFgacw3sDWrvc2UyMrlPdQyvRWc1MWjFkNik5jm
 71B1aOguPFfyKZwocNP/SMGZxoxt7Fxi3QtN/SgpOhysgr/4HrVfbPeGtFHnwA3yIxlG
 Hy1hSEdxdOjsGvN/N6787w1ybzWXCK8WaBatHX4fFVDIF903zPvWinjxuorByNB7ibEF
 PNJoPTEBbn4WH+etQKqD4MGBh97w5FikjrdsLQhlVIen2uh7aIMHYexHO8Nf1B3EvtnK
 Lyg6v4V14wXFCheokSGz5j4y4rdfNOYyvGEP+ZwCp4EZo65ljg2Txcaea91uWAoku77x ag== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2rvwk41a9g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 14:34:46 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3IEYHYK012588;
	Thu, 18 Apr 2019 14:34:45 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rwe7b0mb3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 14:34:45 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3IEYZET027844;
	Thu, 18 Apr 2019 14:34:35 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 18 Apr 2019 07:34:35 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Kees Cook <keescook@google.com>, Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>,
        Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
        Julian Stecklina <jsteckli@amazon.de>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        David Woodhouse <dwmw@amazon.co.uk>,
        Andrew Cooper <andrew.cooper3@citrix.com>,
        Jon Masters <jcm@redhat.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>,
        "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>,
        "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
        Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Khalid Aziz <khalid@gonehiking.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Arjan van de Ven <arjan@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com>
 <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
 <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
 <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
 <CAGXu5jL-qJtW7eH8S2yhqciE+J+FWz8HHzTrGJTgVUbd55n6dQ@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <8f9d059d-e720-cd24-faa6-45493fc012e0@oracle.com>
Date: Thu, 18 Apr 2019 08:34:32 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL-qJtW7eH8S2yhqciE+J+FWz8HHzTrGJTgVUbd55n6dQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9231 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904180098
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9231 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904180098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/17/19 11:41 PM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 11:41 PM Andy Lutomirski <luto@kernel.org> wrot=
e:
>> I don't think this type of NX goof was ever the argument for XPFO.
>> The main argument I've heard is that a malicious user program writes a=

>> ROP payload into user memory (regular anonymous user memory) and then
>> gets the kernel to erroneously set RSP (*not* RIP) to point there.
>=20
> Well, more than just ROP. Any of the various attack primitives. The NX
> stuff is about moving RIP: SMEP-bypassing. But there is still basic
> SMAP-bypassing for putting a malicious structure in userspace and
> having the kernel access it via the linear mapping, etc.
>=20
>> I find this argument fairly weak for a couple reasons.  First, if
>> we're worried about this, let's do in-kernel CFI, not XPFO, to
>=20
> CFI is getting much closer. Getting the kernel happy under Clang, LTO,
> and CFI is under active development. (It's functional for arm64
> already, and pieces have been getting upstreamed.)
>=20

CFI theoretically offers protection with fairly low overhead. I have not
played much with CFI in clang. I agree with Linus that probability of
bugs in XPFO implementation itself is a cause of concern. If CFI in
Clang can provide us the same level of protection as XPFO does, I
wouldn't want to push for an expensive change like XPFO.

If Clang/CFI can't get us there for extended period of time, does it
make sense to continue to poke at XPFO?

Thanks,
Khalid

