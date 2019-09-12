Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 173ABC5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF90F206A5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:35:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF90F206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CDF96B0003; Thu, 12 Sep 2019 06:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F296B0005; Thu, 12 Sep 2019 06:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21F5C6B0006; Thu, 12 Sep 2019 06:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 03A506B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:35:48 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5EA1C181AC9AE
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:35:48 +0000 (UTC)
X-FDA: 75925912776.30.tray75_4fb8665c92f44
X-HE-Tag: tray75_4fb8665c92f44
X-Filterd-Recvd-Size: 4851
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:35:47 +0000 (UTC)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8CAWkkC044720
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:35:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uyhn6pg4v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:35:45 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 12 Sep 2019 11:35:43 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 12 Sep 2019 11:35:41 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8CAZeV220709736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 10:35:40 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5E083AE058;
	Thu, 12 Sep 2019 10:35:40 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 572CAAE051;
	Thu, 12 Sep 2019 10:35:39 +0000 (GMT)
Received: from linux.ibm.com (unknown [9.148.206.179])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 12 Sep 2019 10:35:39 +0000 (GMT)
Date: Thu, 12 Sep 2019 11:35:36 +0100
From: Mike Rapoport <rppt@linux.ibm.com>
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memblock: fix typo in memblock doc
References: <20190911030856.18010-1-caoj.fnst@cn.fujitsu.com>
 <20190911144230.GB6429@linux.ibm.com>
 <59f571f6-785c-7f6e-fd03-5cfc76da27be@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59f571f6-785c-7f6e-fd03-5cfc76da27be@cn.fujitsu.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19091210-4275-0000-0000-00000364D55E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091210-4276-0000-0000-000038772FC3
Message-Id: <20190912103535.GB9062@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-12_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=992 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909120112
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 10:54:09AM +0800, Cao jin wrote:
> On 9/11/19 10:42 PM, Mike Rapoport wrote:
> > On Wed, Sep 11, 2019 at 11:08:56AM +0800, Cao jin wrote:
> >> elaboarte -> elaborate
> >> architecure -> architecture
> >> compltes -> completes
> >>
> >> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> >> ---
> >>  mm/memblock.c | 6 +++---
> >>  1 file changed, 3 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/mm/memblock.c b/mm/memblock.c
> >> index 7d4f61ae666a..0d0f92003d18 100644
> >> --- a/mm/memblock.c
> >> +++ b/mm/memblock.c
> >> @@ -83,16 +83,16 @@
> >>   * Note, that both API variants use implict assumptions about allowed
> >>   * memory ranges and the fallback methods. Consult the documentation
> >>   * of :c:func:`memblock_alloc_internal` and
> >> - * :c:func:`memblock_alloc_range_nid` functions for more elaboarte
> >> + * :c:func:`memblock_alloc_range_nid` functions for more elaborate
> > 
> > While on it, could you please replace the
> > :c:func:`memblock_alloc_range_nid` construct with
> > memblock_alloc_range_nid()?
> > 
> > And that would be really great to see all the :c:func:`foo` changed to
> > foo().
> > 
> 
> Sure. BTW, do you want convert all the markups too?
> 
>     :c:type:`foo` -> struct foo
>     %FOO -> FOO
>     ``foo`` -> foo
>     **foo** -> foo

The documentation toolchain can recognize now foo() as a function and does
not require the :c:func: prefix for that. AFAIK it only works for
functions, so please don't change the rest of the markup.
 
> -- 
> Sincerely,
> Cao jin
> 
> 

-- 
Sincerely yours,
Mike.


