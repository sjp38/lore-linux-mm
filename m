Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E71EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3D5520835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QSc54vhj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3D5520835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FA6A6B0007; Wed, 17 Apr 2019 12:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AC816B0008; Wed, 17 Apr 2019 12:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5993D6B000A; Wed, 17 Apr 2019 12:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4A76B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:50:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d1so14946251pgk.21
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:50:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Pt0iK48BFNYGn2PcXPZIgKCS+ChPFURYRr28gHDNt5M=;
        b=OoMv/4+YSLqpyW/btgVSOm48HV+tFcwWRkwj8bYV39xCJBOLBOVtEMlXn3q6Fq0V5f
         3YTmmAbLxmYbmB1qCfV1JfDbViwiielE5OoLB0HkVaLpT+KntYFWvxWsdthm/pirUljg
         9h6dNHnqwUowxzdHkll5G+hWiLviU5aGZFKbiulyaMvJZ8MNH4YpI+9PKxK6D7PtGFDn
         AV3t5hubmMCKwWKk+ItT7R195ndwYB5JJs/WFA7EkP9aU0dPn+Rwwzym7GH3HUxRc914
         +cjA6o80cShKFSDqrmQYUF/6tD9eNm7fyfHlP/Gr0B2FXiMxNl1ksF8NyIbxQ6NHD8vA
         azAw==
X-Gm-Message-State: APjAAAX3QZUDKTVJme0VASmLylorUd4Q6DgRf+A1pwibVyLU95WKhpgp
	rWPT1TzlfyAoLeUwqOhiIklS7LLnMMeD4LnuDPUK6MTEaWE1W1zW5bE5W4XNFfun2C7SF3GADtc
	PiJrhRgeM/e03N1irViWzZm0sk3n8ZUHrrED/zhM7jUf2y1YNl3qONyzQ2pBX8sZobA==
X-Received: by 2002:a63:1064:: with SMTP id 36mr83660963pgq.155.1555519838582;
        Wed, 17 Apr 2019 09:50:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuWKovPSsf7FT/ykrC0xB6wHyzbtUBy71ts2JyapAfXgjZgqLEpg9epR5NRJpxyNl0J3qm
X-Received: by 2002:a63:1064:: with SMTP id 36mr83660796pgq.155.1555519835814;
        Wed, 17 Apr 2019 09:50:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555519835; cv=none;
        d=google.com; s=arc-20160816;
        b=dQMH9BKD35JeaTdbX0Lgl/9eLix9kJ1Zso2dYdlLqcMeE3HYPM4FQWp4p93mk0MYwR
         n0ER2J+/Hy8TWwj8utCHP4jt3VentKb3O6MKp2lNCjVX4m0cNCq+GcTgqjS68eJ1AuS/
         x8eMQqn3VwM7WiHJtAzOYLFjDpu9noNS3XgXxk0uvRhnZxlNwdg5Jf3YPLk3Z5yXSPTu
         9yOZcXqf5mUR4snoB+9bX9WtAU7lwkefiEH1GvSbXoT1eDnuvh0P8iRBsUGN1wcjPg/M
         TJ7fDlJ+83BIRftFBG4uX20vGR39+ACr9JWZ/ptf6zbabyvJu7Nub87E0CriFv4zv5b8
         A9/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=Pt0iK48BFNYGn2PcXPZIgKCS+ChPFURYRr28gHDNt5M=;
        b=VSMYNMIJ6NLgeUJiZXaLCL8Zw485DUcOQzaA6XCFPN3v6xqge/EfFVtFX4iBlRKKJw
         xZ75n2RTdZvrLo+vPa+MgNJ+h9usjvXVXm38iib9B4ndCrUb04e8xwiOSf16afaPypZw
         an/dRmCj1HbkHuqLGW8/WTuOLqH7n6C3KXC5dz4LurzMAHYrdK4HY23LYvWTJAhRXVuU
         6C80M+UVZ2lVSn67bs2OolYW1kMlcUFcFEce/1kev3YwnHr8wjxTcDZoXU/ZSxI/wqGY
         ACaSZuBifcdDdhnn7fkNNWEPC5vgkla9m3rlPLNO65ZwhFBPLSS5nFC5U6zi1d2I37q4
         35vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QSc54vhj;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t18si46703611plo.113.2019.04.17.09.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 09:50:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QSc54vhj;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HGnG3X054958;
	Wed, 17 Apr 2019 16:49:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Pt0iK48BFNYGn2PcXPZIgKCS+ChPFURYRr28gHDNt5M=;
 b=QSc54vhjKse2Gq1rcTB1KDv+n5ZNYuiktD723uSnPsQg7/lU0erFzUS/U+FBFZ5v5LN9
 4iDgkm0iqKmiYtxwHEIhhS/dZpybhW0dtoiBsKHfsRiNS/33zdpDmnSeEYaMYsWJC471
 dCGjeqzxijoOujPRbY2v3RHQK3LQ0lDNqJDLxAdspRBmSrV8REgdAzENjYqfKctb9EN3
 ONxMYYcd+On4oXsuj8M0FhxjRbw/Mu/K0czjCGbHDVfpbP3Gtg6t7AiiaqxMW+yFQXEF
 2d2DLE521La9q/IPFvG820wM8B3HmquyOp/lJk9noCrcYUs7OpW7XPbO3bgHsYkbl4gL UQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rvwk3v9bb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 16:49:35 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HGmQda049331;
	Wed, 17 Apr 2019 16:49:34 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2rv2tvg02m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 16:49:34 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3HGnUSU030371;
	Wed, 17 Apr 2019 16:49:30 GMT
Received: from [10.65.150.207] (/10.65.150.207)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 09:49:29 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Ingo Molnar <mingo@kernel.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, keescook@google.com,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Arjan van de Ven <arjan@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
Date: Wed, 17 Apr 2019 10:49:26 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190417161042.GA43453@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170113
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/17/19 10:15 AM, Ingo Molnar wrote:
>=20
> [ Sorry, had to trim the Cc: list from hell. Tried to keep all the=20
>   mailing lists and all x86 developers. ]
>=20
> * Khalid Aziz <khalid.aziz@oracle.com> wrote:
>=20
>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>
>> This patch adds basic support infrastructure for XPFO which protects=20
>> against 'ret2dir' kernel attacks. The basic idea is to enforce=20
>> exclusive ownership of page frames by either the kernel or userspace, =

>> unless explicitly requested by the kernel. Whenever a page destined fo=
r=20
>> userspace is allocated, it is unmapped from physmap (the kernel's page=
=20
>> table). When such a page is reclaimed from userspace, it is mapped bac=
k=20
>> to physmap. Individual architectures can enable full XPFO support usin=
g=20
>> this infrastructure by supplying architecture specific pieces.
>=20
> I have a higher level, meta question:
>=20
> Is there any updated analysis outlining why this XPFO overhead would be=
=20
> required on x86-64 kernels running on SMAP/SMEP CPUs which should be al=
l=20
> recent Intel and AMD CPUs, and with kernel that mark all direct kernel =

> mappings as non-executable - which should be all reasonably modern=20
> kernels later than v4.0 or so?
>=20
> I.e. the original motivation of the XPFO patches was to prevent executi=
on=20
> of direct kernel mappings. Is this motivation still present if those=20
> mappings are non-executable?
>=20
> (Sorry if this has been asked and answered in previous discussions.)

Hi Ingo,

That is a good question. Because of the cost of XPFO, we have to be very
sure we need this protection. The paper from Vasileios, Michalis and
Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
and 6.2.

Thanks,
Khalid


