Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8041C49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 778502053B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 778502053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D4D6B000D; Wed, 11 Sep 2019 10:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01E506B000E; Wed, 11 Sep 2019 10:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2AAE6B0010; Wed, 11 Sep 2019 10:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id BF14E6B000D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:44:55 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 63E5A8243770
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:44:55 +0000 (UTC)
X-FDA: 75922911750.23.back08_dd3308ff9444
X-HE-Tag: back08_dd3308ff9444
X-Filterd-Recvd-Size: 4688
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:44:54 +0000 (UTC)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8BEipBP140002
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:44:54 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uy0caxadf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:44:52 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 11 Sep 2019 15:42:38 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 11 Sep 2019 15:42:36 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8BEgZPu53477490
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 11 Sep 2019 14:42:35 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 70FECAE059;
	Wed, 11 Sep 2019 14:42:35 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 737ADAE056;
	Wed, 11 Sep 2019 14:42:34 +0000 (GMT)
Received: from linux.ibm.com (unknown [9.148.207.74])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 11 Sep 2019 14:42:34 +0000 (GMT)
Date: Wed, 11 Sep 2019 15:42:31 +0100
From: Mike Rapoport <rppt@linux.ibm.com>
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memblock: fix typo in memblock doc
References: <20190911030856.18010-1-caoj.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911030856.18010-1-caoj.fnst@cn.fujitsu.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19091114-0016-0000-0000-000002AA0E49
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091114-0017-0000-0000-0000330A9B22
Message-Id: <20190911144230.GB6429@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-11_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909110138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 11:08:56AM +0800, Cao jin wrote:
> elaboarte -> elaborate
> architecure -> architecture
> compltes -> completes
> 
> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> ---
>  mm/memblock.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7d4f61ae666a..0d0f92003d18 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -83,16 +83,16 @@
>   * Note, that both API variants use implict assumptions about allowed
>   * memory ranges and the fallback methods. Consult the documentation
>   * of :c:func:`memblock_alloc_internal` and
> - * :c:func:`memblock_alloc_range_nid` functions for more elaboarte
> + * :c:func:`memblock_alloc_range_nid` functions for more elaborate

While on it, could you please replace the
:c:func:`memblock_alloc_range_nid` construct with
memblock_alloc_range_nid()?

And that would be really great to see all the :c:func:`foo` changed to
foo().

>   * description.
>   *
>   * As the system boot progresses, the architecture specific
>   * :c:func:`mem_init` function frees all the memory to the buddy page
>   * allocator.
>   *
> - * Unless an architecure enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
> + * Unless an architecture enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
>   * memblock data structures will be discarded after the system
> - * initialization compltes.
> + * initialization completes.
>   */
>  
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
> -- 
> 2.21.0
> 
> 
> 

-- 
Sincerely yours,
Mike.


