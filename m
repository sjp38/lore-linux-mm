Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63576C3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:01:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31D34205C9
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:01:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31D34205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF566B0008; Mon, 19 Aug 2019 09:01:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79206B000A; Mon, 19 Aug 2019 09:01:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940CB6B000C; Mon, 19 Aug 2019 09:01:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8CA6B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:01:09 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 11A43181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:01:09 +0000 (UTC)
X-FDA: 75839187858.24.kiss14_61458e4e69712
X-HE-Tag: kiss14_61458e4e69712
X-Filterd-Recvd-Size: 4668
Received: from mx0b-002e3701.pphosted.com (mx0b-002e3701.pphosted.com [148.163.143.35])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:01:08 +0000 (UTC)
Received: from pps.filterd (m0150244.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7JD0dZN003311;
	Mon, 19 Aug 2019 13:00:59 GMT
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com [15.233.44.26])
	by mx0b-002e3701.pphosted.com with ESMTP id 2ufstss48m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 19 Aug 2019 13:00:59 +0000
Received: from g2t2360.austin.hpecorp.net (g2t2360.austin.hpecorp.net [16.196.225.135])
	by g2t2353.austin.hpe.com (Postfix) with ESMTP id 703C496;
	Mon, 19 Aug 2019 13:00:58 +0000 (UTC)
Received: from hpe.com (teo-eag.americas.hpqcorp.net [10.33.152.10])
	by g2t2360.austin.hpecorp.net (Postfix) with ESMTP id 660EF39;
	Mon, 19 Aug 2019 13:00:57 +0000 (UTC)
Date: Mon, 19 Aug 2019 08:00:57 -0500
From: Dimitri Sivanich <sivanich@hpe.com>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: sivanich@hpe.com, jhubbard@nvidia.com, jglisse@redhat.com,
        ira.weiny@intel.com, gregkh@linuxfoundation.org, arnd@arndb.de,
        william.kucharski@oracle.com, hch@lst.de, linux-mm@kvack.org,
        linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org
Subject: Re: [Linux-kernel-mentees][PATCH 2/2] sgi-gru: Remove uneccessary
 ifdef for CONFIG_HUGETLB_PAGE
Message-ID: <20190819130057.GC5808@hpe.com>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190148
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>

On Mon, Aug 19, 2019 at 01:08:55AM +0530, Bharath Vedartham wrote:
> is_vm_hugetlb_page will always return false if CONFIG_HUGETLB_PAGE is
> not set.
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: William Kucharski <william.kucharski@oracle.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel-mentees@lists.linuxfoundation.org
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 21 +++++++++++----------
>  1 file changed, 11 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/gru=
fault.c
> index 61b3447..bce47af 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -180,11 +180,11 @@ static int non_atomic_pte_lookup(struct vm_area_s=
truct *vma,
>  {
>  	struct page *page;
> =20
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift =3D HPAGE_SHIFT;
> +	else
> +		*pageshift =3D PAGE_SHIFT;
> +
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D=
 0)
>  		return -EFAULT;
>  	*paddr =3D page_to_phys(page);
> @@ -238,11 +238,12 @@ static int atomic_pte_lookup(struct vm_area_struc=
t *vma, unsigned long vaddr,
>  		return 1;
> =20
>  	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift =3D HPAGE_SHIFT;
> +	else
> +		*pageshift =3D PAGE_SHIFT;
> +
>  	return 0;
> =20
>  err:
> --=20
> 2.7.4
>=20

