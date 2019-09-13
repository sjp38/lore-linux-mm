Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D17A5C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:55:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80E8D20640
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 13:55:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E8D20640
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E42976B0005; Fri, 13 Sep 2019 09:55:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF16C6B0006; Fri, 13 Sep 2019 09:55:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE1506B0007; Fri, 13 Sep 2019 09:55:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id ADE2D6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:55:48 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2F4CC824376E
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:55:48 +0000 (UTC)
X-FDA: 75930045576.19.neck25_89ebe228c7b56
X-HE-Tag: neck25_89ebe228c7b56
X-Filterd-Recvd-Size: 11716
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 13:55:47 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8DDrbLI002213
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:55:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v0c2y0x4a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:55:46 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 13 Sep 2019 14:55:45 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 13 Sep 2019 14:55:41 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8DDtetk11993488
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 13:55:40 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C43A8AE056;
	Fri, 13 Sep 2019 13:55:40 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 182F9AE045;
	Fri, 13 Sep 2019 13:55:40 +0000 (GMT)
Received: from pomme.local (unknown [9.145.181.150])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 13:55:39 +0000 (GMT)
Subject: Re: [PATCH 2/3] powperc/mm: read TLB Block Invalidate Characteristics
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
 <20190830120712.22971-3-ldufour@linux.ibm.com>
 <e809e33f-58df-ec99-44e8-9b1ae0b6bfe0@linux.ibm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 13 Sep 2019 15:55:39 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <e809e33f-58df-ec99-44e8-9b1ae0b6bfe0@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
x-cbid: 19091313-4275-0000-0000-0000036551FE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091313-4276-0000-0000-00003877B00E
Message-Id: <5b5dfa47-43a0-5035-d620-addca4549bf7@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130137
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 12/09/2019 =C3=A0 16:16, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
> On 8/30/19 5:37 PM, Laurent Dufour wrote:
>> The PAPR document specifies the TLB Block Invalidate Characteristics w=
hich
>> is telling which couple base page size / page size is supported by the
>> H_BLOCK_REMOVE hcall.
>>
>> A new set of feature is added to the mmu_psize_def structure to record=
 per
>> base page size which page size is supported by H_BLOCK_REMOVE.
>>
>> A new init service is added to read the characteristics. The size of t=
he
>> buffer is set to twice the number of known page size, plus 10 bytes to
>> ensure we have enough place.
>>
>=20
>=20
> So this is not really the base page size/actual page size combination. =
This=20
> is related to H_BLOCK_REMOVE hcall, block size supported by that HCALL =
and=20
> what page size combination is supported with that specific block size.

I agree

>=20
> We should add that TLB block invalidate characteristics format in this =
patch.

Sure, will do that in a comment inside the code.

>=20
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>> =C2=A0 arch/powerpc/include/asm/book3s/64/mmu.h |=C2=A0=C2=A0 3 +
>> =C2=A0 arch/powerpc/platforms/pseries/lpar.c=C2=A0=C2=A0=C2=A0 | 107 +=
++++++++++++++++++++++
>> =C2=A0 2 files changed, 110 insertions(+)
>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h=20
>> b/arch/powerpc/include/asm/book3s/64/mmu.h
>> index 23b83d3593e2..675895dfe39f 100644
>> --- a/arch/powerpc/include/asm/book3s/64/mmu.h
>> +++ b/arch/powerpc/include/asm/book3s/64/mmu.h
>> @@ -12,11 +12,14 @@
>> =C2=A0=C2=A0 *=C2=A0=C2=A0=C2=A0 sllp=C2=A0 : is a bit mask with the v=
alue of SLB L || LP to be or'ed
>> =C2=A0=C2=A0 *=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 directly to a slbmte "vsid" value
>> =C2=A0=C2=A0 *=C2=A0=C2=A0=C2=A0 penc=C2=A0 : is the HPTE encoding mas=
k for the "LP" field:
>> + *=C2=A0=C2=A0=C2=A0 hblk=C2=A0 : H_BLOCK_REMOVE supported block size=
 for this page size in
>> + *=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
segment who's base page size is that page size.
>> =C2=A0=C2=A0 *
>> =C2=A0=C2=A0 */
>> =C2=A0 struct mmu_psize_def {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int=C2=A0=C2=A0=C2=A0 shift;=C2=
=A0=C2=A0=C2=A0 /* number of bits */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 penc[MMU_PAGE_COUNT];=C2=A0=C2=A0=C2=A0 /* HPTE encoding */
>> +=C2=A0=C2=A0=C2=A0 int=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 hblk=
[MMU_PAGE_COUNT];=C2=A0=C2=A0=C2=A0 /* H_BLOCK_REMOVE support */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int=C2=A0=C2=A0=C2=A0 tlbiel;=C2=
=A0=C2=A0=C2=A0 /* tlbiel supported for that page size */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned long=C2=A0=C2=A0=C2=A0 avpnm;=C2=
=A0=C2=A0=C2=A0 /* bits to mask out in AVPN in the HPTE */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 union {
>> diff --git a/arch/powerpc/platforms/pseries/lpar.c=20
>> b/arch/powerpc/platforms/pseries/lpar.c
>> index 4f76e5f30c97..375e19b3cf53 100644
>> --- a/arch/powerpc/platforms/pseries/lpar.c
>> +++ b/arch/powerpc/platforms/pseries/lpar.c
>> @@ -1311,6 +1311,113 @@ static void do_block_remove(unsigned long numb=
er,=20
>> struct ppc64_tlb_batch *batch,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 (void)call_bloc=
k_remove(pix, param, true);
>> =C2=A0 }
>> +static inline void __init set_hblk_bloc_size(int bpsize, int psize,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 unsigned int block_size)
>> +{
>> +=C2=A0=C2=A0=C2=A0 struct mmu_psize_def *def =3D &mmu_psize_defs[bpsi=
ze];
>> +
>> +=C2=A0=C2=A0=C2=A0 if (block_size > def->hblk[psize])
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 def->hblk[psize] =3D block=
_size;
>> +}
>> +
>> +static inline void __init check_lp_set_hblk(unsigned int lp,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 uns=
igned int block_size)
>> +{
>> +=C2=A0=C2=A0=C2=A0 unsigned int bpsize, psize;
>> +
>> +
>> +=C2=A0=C2=A0=C2=A0 /* First, check the L bit, if not set, this means =
4K */
>> +=C2=A0=C2=A0=C2=A0 if ((lp & 0x80) =3D=3D 0) {
>=20
>=20
> What is that 0x80? We should have #define for most of those.

I will make that more explicit through a define

>=20
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 set_hblk_bloc_size(MMU_PAG=
E_4K, MMU_PAGE_4K, block_size);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 /* PAPR says to look at bits 2-7 (0 =3D MSB) */
>> +=C2=A0=C2=A0=C2=A0 lp &=3D 0x3f;
>=20
> Also convert that to #define?

Really ? The comment above is explicitly saying that we are looking at bi=
ts=20
2-7. A define will obfuscate that.

>=20
>> +=C2=A0=C2=A0=C2=A0 for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize=
++) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct mmu_psize_def *def =
=3D=C2=A0 &mmu_psize_defs[bpsize];
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (psize =3D 0; psize < =
MMU_PAGE_COUNT; psize++) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if=
 (def->penc[psize] =3D=3D lp) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 set_hblk_bloc_size(bpsize, psize, block_size);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0 }
>> +}
>> +
>> +#define SPLPAR_TLB_BIC_TOKEN=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 50
>> +#define SPLPAR_TLB_BIC_MAXLENGTH=C2=A0=C2=A0=C2=A0 (MMU_PAGE_COUNT*2 =
+ 10)
>> +static int __init read_tlbbi_characteristics(void)
>> +{
>> +=C2=A0=C2=A0=C2=A0 int call_status;
>> +=C2=A0=C2=A0=C2=A0 unsigned char local_buffer[SPLPAR_TLB_BIC_MAXLENGT=
H];
>> +=C2=A0=C2=A0=C2=A0 int len, idx, bpsize;
>> +
>> +=C2=A0=C2=A0=C2=A0 if (!firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)=
) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_info("H_BLOCK_REMOVE is=
 not supported");
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 memset(local_buffer, 0, SPLPAR_TLB_BIC_MAXLENGTH);
>> +
>> +=C2=A0=C2=A0=C2=A0 spin_lock(&rtas_data_buf_lock);
>> +=C2=A0=C2=A0=C2=A0 memset(rtas_data_buf, 0, RTAS_DATA_BUF_SIZE);
>> +=C2=A0=C2=A0=C2=A0 call_status =3D rtas_call(rtas_token("ibm,get-syst=
em-parameter"), 3, 1,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 NULL,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 SPLPAR_TLB_BIC_TOKEN,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 __pa(rtas_data_buf),
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 RTAS_DATA_BUF_SIZE);
>> +=C2=A0=C2=A0=C2=A0 memcpy(local_buffer, rtas_data_buf, SPLPAR_TLB_BIC=
_MAXLENGTH);
>> +=C2=A0=C2=A0=C2=A0 local_buffer[SPLPAR_TLB_BIC_MAXLENGTH - 1] =3D '\0=
';
>> +=C2=A0=C2=A0=C2=A0 spin_unlock(&rtas_data_buf_lock);
>> +
>> +=C2=A0=C2=A0=C2=A0 if (call_status !=3D 0) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_warn("%s %s Error calli=
ng get-system-parameter (0x%x)\n",
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __=
FILE__, __func__, call_status);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * The first two (2) bytes of the data in the=
 buffer are the length of
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * the returned data, not counting these firs=
t two (2) bytes.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 len =3D local_buffer[0] * 256 + local_buffer[1] + =
2;
>> +=C2=A0=C2=A0=C2=A0 if (len >=3D SPLPAR_TLB_BIC_MAXLENGTH) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_warn("%s too large retu=
rned buffer %d", __func__, len);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 idx =3D 2;
>> +=C2=A0=C2=A0=C2=A0 while (idx < len) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int block_size =3D=
 local_buffer[idx++];
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned int npsize;
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!block_size)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 br=
eak;
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 block_size =3D 1 << block_=
size;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (block_size !=3D 8)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /*=
 We only support 8 bytes size TLB invalidate buffer */
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr=
_warn("Unsupported H_BLOCK_REMOVE block size : %d\n",
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 block_size);
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (npsize =3D local_buff=
er[idx++];=C2=A0 npsize > 0; npsize--)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ch=
eck_lp_set_hblk((unsigned int) local_buffer[idx++],
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 block_size);
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize=
++)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (idx =3D 0; idx < MMU_=
PAGE_COUNT; idx++)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if=
 (mmu_psize_defs[bpsize].hblk[idx])
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 pr_info("H_BLOCK_REMOVE supports base psize:%d psiz=
e:%d=20
>> block size:%d",
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bpsize, idx,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mmu_psize_defs[bpsize].hblk=
[idx]);
>> +
>> +=C2=A0=C2=A0=C2=A0 return 0;
>> +}
>> +machine_arch_initcall(pseries, read_tlbbi_characteristics);
>> +
>=20
> Why a machine_arch_initcall() ? Can't we do this similar to how we do=20
> segment-page-size parsing from device tree? Also this should be hash=20
> translation mode specific.

Because that code is specific to the pseries architecture. the hash=20
translation is not pseries specific.

Indeed the change in mmu_psize_defs is not too generic. The hblk=20
characteristics should remain static to the lpar.c file where it is used.

>=20
>> =C2=A0 /*
>> =C2=A0=C2=A0 * Take a spinlock around flushes to avoid bouncing the hy=
pervisor tlbie
>> =C2=A0=C2=A0 * lock.
>>
>=20


