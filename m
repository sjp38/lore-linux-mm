Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A0C7C4CEC6
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 05:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B87320830
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 05:16:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B87320830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 891A26B0003; Sun, 15 Sep 2019 01:16:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 841CA6B0006; Sun, 15 Sep 2019 01:16:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72E886B0007; Sun, 15 Sep 2019 01:16:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 4C74B6B0003
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 01:16:49 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E52348243762
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 05:16:48 +0000 (UTC)
X-FDA: 75935995296.08.feast41_58856daa32843
X-HE-Tag: feast41_58856daa32843
X-Filterd-Recvd-Size: 7298
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 05:16:48 +0000 (UTC)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8F5CQxV137516
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 01:16:47 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v1dk4hnvv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 01:16:47 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 15 Sep 2019 06:16:45 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 15 Sep 2019 06:16:43 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8F5GHlo34013682
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 15 Sep 2019 05:16:17 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E148CA404D;
	Sun, 15 Sep 2019 05:16:42 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8A74CA4040;
	Sun, 15 Sep 2019 05:16:42 +0000 (GMT)
Received: from linux.ibm.com (unknown [9.148.8.160])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 15 Sep 2019 05:16:42 +0000 (GMT)
Date: Sun, 15 Sep 2019 08:16:40 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memblock: cleanup doc
References: <20190912123127.8694-1-caoj.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912123127.8694-1-caoj.fnst@cn.fujitsu.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19091505-0012-0000-0000-0000034BBAA5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091505-0013-0000-0000-000021862D80
Message-Id: <20190915051640.GA11429@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-15_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909150056
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 08:31:27PM +0800, Cao jin wrote:
> fix typos for:
>     elaboarte -> elaborate
>     architecure -> architecture
>     compltes -> completes
> 
> And, convert the markup :c:func:`foo` to foo() as kernel documentation
> toolchain can recognize foo() as a function.
> 
> Suggested-by: Mike Rapoport <rppt@linux.ibm.com>
> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/memblock.c | 44 ++++++++++++++++++++------------------------
>  1 file changed, 20 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7d4f61ae666a..c23b370cc49e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -57,42 +57,38 @@
>   * at build time. The region arrays for the "memory" and "reserved"
>   * types are initially sized to %INIT_MEMBLOCK_REGIONS and for the
>   * "physmap" type to %INIT_PHYSMEM_REGIONS.
> - * The :c:func:`memblock_allow_resize` enables automatic resizing of
> - * the region arrays during addition of new regions. This feature
> - * should be used with care so that memory allocated for the region
> - * array will not overlap with areas that should be reserved, for
> - * example initrd.
> + * The memblock_allow_resize() enables automatic resizing of the region
> + * arrays during addition of new regions. This feature should be used
> + * with care so that memory allocated for the region array will not
> + * overlap with areas that should be reserved, for example initrd.
>   *
>   * The early architecture setup should tell memblock what the physical
> - * memory layout is by using :c:func:`memblock_add` or
> - * :c:func:`memblock_add_node` functions. The first function does not
> - * assign the region to a NUMA node and it is appropriate for UMA
> - * systems. Yet, it is possible to use it on NUMA systems as well and
> - * assign the region to a NUMA node later in the setup process using
> - * :c:func:`memblock_set_node`. The :c:func:`memblock_add_node`
> - * performs such an assignment directly.
> + * memory layout is by using memblock_add() or memblock_add_node()
> + * functions. The first function does not assign the region to a NUMA
> + * node and it is appropriate for UMA systems. Yet, it is possible to
> + * use it on NUMA systems as well and assign the region to a NUMA node
> + * later in the setup process using memblock_set_node(). The
> + * memblock_add_node() performs such an assignment directly.
>   *
>   * Once memblock is setup the memory can be allocated using one of the
>   * API variants:
>   *
> - * * :c:func:`memblock_phys_alloc*` - these functions return the
> - *   **physical** address of the allocated memory
> - * * :c:func:`memblock_alloc*` - these functions return the **virtual**
> - *   address of the allocated memory.
> + * * memblock_phys_alloc*() - these functions return the **physical**
> + *   address of the allocated memory
> + * * memblock_alloc*() - these functions return the **virtual** address
> + *   of the allocated memory.
>   *
>   * Note, that both API variants use implict assumptions about allowed
>   * memory ranges and the fallback methods. Consult the documentation
> - * of :c:func:`memblock_alloc_internal` and
> - * :c:func:`memblock_alloc_range_nid` functions for more elaboarte
> - * description.
> + * of memblock_alloc_internal() and memblock_alloc_range_nid()
> + * functions for more elaborate description.
>   *
> - * As the system boot progresses, the architecture specific
> - * :c:func:`mem_init` function frees all the memory to the buddy page
> - * allocator.
> + * As the system boot progresses, the architecture specific mem_init()
> + * function frees all the memory to the buddy page allocator.
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


