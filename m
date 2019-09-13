Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FF4EC4CEC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 02:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ADD820693
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 02:00:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ADD820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C622C6B0007; Thu, 12 Sep 2019 22:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C15756B0008; Thu, 12 Sep 2019 22:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B28156B000A; Thu, 12 Sep 2019 22:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id A3C676B0007
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 22:00:57 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7682E824376B
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:00:57 +0000 (UTC)
X-FDA: 75928244154.30.nest50_84be8213c445
X-HE-Tag: nest50_84be8213c445
X-Filterd-Recvd-Size: 5954
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:00:56 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8D1ud3I117254;
	Thu, 12 Sep 2019 22:00:50 -0400
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uywn4xv48-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 12 Sep 2019 22:00:50 -0400
Received: from m0098394.ppops.net (m0098394.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x8D1vR0D124274;
	Thu, 12 Sep 2019 22:00:49 -0400
Received: from ppma03wdc.us.ibm.com (ba.79.3fa9.ip4.static.sl-reverse.com [169.63.121.186])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uywn4xv3h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 12 Sep 2019 22:00:49 -0400
Received: from pps.filterd (ppma03wdc.us.ibm.com [127.0.0.1])
	by ppma03wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x8D1sm19022449;
	Fri, 13 Sep 2019 02:00:48 GMT
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by ppma03wdc.us.ibm.com with ESMTP id 2uytdx37je-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 13 Sep 2019 02:00:48 +0000
Received: from b03ledav005.gho.boulder.ibm.com (b03ledav005.gho.boulder.ibm.com [9.17.130.236])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8D20lSw46858692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 02:00:47 GMT
Received: from b03ledav005.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1E896BE058;
	Fri, 13 Sep 2019 02:00:47 +0000 (GMT)
Received: from b03ledav005.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7F809BE04F;
	Fri, 13 Sep 2019 02:00:44 +0000 (GMT)
Received: from [9.199.46.176] (unknown [9.199.46.176])
	by b03ledav005.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 02:00:44 +0000 (GMT)
Subject: Re: [PATCH 2/3] powperc/mm: read TLB Block Invalidate Characteristics
To: Laurent Dufour <ldufour@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
 <20190830120712.22971-3-ldufour@linux.ibm.com> <87impxshfk.fsf@linux.ibm.com>
 <468a53a6-a970-5526-8035-eef59dcf48ed@linux.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Message-ID: <97bafb53-6ae9-1d42-1816-ef81b845b80c@linux.ibm.com>
Date: Fri, 13 Sep 2019 07:30:42 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <468a53a6-a970-5526-8035-eef59dcf48ed@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=856 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130019
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/13/19 12:56 AM, Laurent Dufour wrote:
> Le 12/09/2019 =C3=A0 16:44, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
>> Laurent Dufour <ldufour@linux.ibm.com> writes:

>>> +
>>> +=C2=A0=C2=A0=C2=A0 idx =3D 2;
>>> +=C2=A0=C2=A0=C2=A0 while (idx < len) {
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int block_size =3D=
 local_buffer[idx++];
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int npsize;
>>> +
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!block_size)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 b=
reak;
>>> +
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 block_size =3D 1 << block=
_size;
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (block_size !=3D 8)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /=
* We only support 8 bytes size TLB invalidate buffer */
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p=
r_warn("Unsupported H_BLOCK_REMOVE block size : %d\n",
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 block_size);
>>
>> Should we skip setting block size if we find block_size !=3D 8? Also c=
an
>> we avoid doing that pr_warn in loop and only warn if we don't find
>> block_size 8 in the invalidate characteristics array?
>=20
> My idea here is to fully read and process the data returned by the=20
> hcall, and to put the limitation to 8 when checking before calling=20
> H_BLOCK_REMOVE.
> The warning is there because I want it to be displayed once at boot.
>=20


Can we have two block size reported for the same base page size/actual=20
page size combination? If so we will overwrite the hblk[actual_psize] ?

>>
>>> +
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (npsize =3D local_buf=
fer[idx++];=C2=A0 npsize > 0; npsize--)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 c=
heck_lp_set_hblk((unsigned int) local_buffer[idx++],
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 block_size);
>>> +=C2=A0=C2=A0=C2=A0 }
>>> +
>>> +=C2=A0=C2=A0=C2=A0 for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsiz=
e++)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (idx =3D 0; idx < MMU=
_PAGE_COUNT; idx++)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 i=
f (mmu_psize_defs[bpsize].hblk[idx])
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 pr_info("H_BLOCK_REMOVE supports base psize:%d=20
>>> psize:%d block size:%d",
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bpsize, idx,
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mmu_psize_defs[bpsize].hblk=
[idx]);
>>> +
>>> +=C2=A0=C2=A0=C2=A0 return 0;
>>> +}
>>> +machine_arch_initcall(pseries, read_tlbbi_characteristics);
>>> +
>>> =C2=A0 /*
>>> =C2=A0=C2=A0 * Take a spinlock around flushes to avoid bouncing the h=
ypervisor=20
>>> tlbie
>>> =C2=A0=C2=A0 * lock.

-aneesh

