Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8945C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58C8E2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:35:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58C8E2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB0FC8E00CC; Mon, 11 Feb 2019 02:35:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B605F8E00C4; Mon, 11 Feb 2019 02:35:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28158E00CC; Mon, 11 Feb 2019 02:35:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 624528E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:35:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t65so4798020pfj.19
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 23:35:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=xmYYhT/NunsdPiHabn6Y/TtAP5zptX6cTxluQ+QGMek=;
        b=Y6ANvrAKZYRNvVwtHXn05miDeQanxUni7hwztcXG4rWU76A3GbBH43uH9JxvGHlBEW
         MkHSAS7v97J7oGpl1Lw6uM7x6/mUbdSDn8+nUQcnM4nPGbSbAEd0SQgk1F8la8FMX7wA
         3c5jbG8mYWw+zlMe1QVUkVAoT/qbWTfsTNlVFJx7qdsq9/sxoxu4FNfa1eVuJyRxe9fq
         DjI/588p6EyXoS8yJQHZv+PpacjRw999Ro0iYeHqX+/GJFEJdi0QjNfgfgx421fNFLrQ
         YzDi5h47rgydPv4rUldVztaypk4aRwuNmIICIAj6Y9OOgJTH/M1J0Av4dJL1Lj/qZ6P9
         eODQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubGFk1T6QrdlVvvNxYgj5gRFmyY6ovjvOEBDN6CH6ROmQy1L8XR
	Dg3NpUiEnShkyEuuz+0V5bCvvfbzRpsRyDSEGJ83KgOZhnmaHWoagzwQtLjcDbVwstSU/dHbvFP
	KoGISHpqXhYEsfHDFawFOvGyK2MfK2198BM1Io3lA/pvC0vuts/6GGrgLylb9aB2p2A==
X-Received: by 2002:a62:6e07:: with SMTP id j7mr36272059pfc.135.1549870549001;
        Sun, 10 Feb 2019 23:35:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbXsNAsXmUYB4ixZkCJmOhNXj6jBjOhBI1K1H7Jnl5NNoHZeWUFICUDC34wdtPTLLC/bVT1
X-Received: by 2002:a62:6e07:: with SMTP id j7mr36272010pfc.135.1549870548343;
        Sun, 10 Feb 2019 23:35:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549870548; cv=none;
        d=google.com; s=arc-20160816;
        b=lSlEJz2dZAGWKrK3Y/mN3nQJCN8cV3b6OFXVRD8uN4cZaAxQLcK55LZtrUYYlA1xP9
         O68ce+I7p6uwqGfJo2rDMfF4Uju1WFM21//sUN3YY/hfoonRgOAtQeKFqy5JVqrw/JMe
         IY5M0I8S3VdV63Lsjq4EoFZWHHmmZNSxlWehYqlZvIWq0QU62QD8WExZCsDNxJO/dbn3
         lOY29s/OPzIf4aHEzLaVDUDCN8S8lHme0WYlw3aQhWQ+H5rScFEpWAUapLrvewcc8WCJ
         05Shd+gMMS0C+xk0hEaBkwB2RNyTOcfTHz1ALBwGiMFdhCFkpIj/vN9hIzFPvVcr0H+s
         0R2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=xmYYhT/NunsdPiHabn6Y/TtAP5zptX6cTxluQ+QGMek=;
        b=sxkRen8jGSK3wCV2Zvu8EdFe/gQUoMWvufgORFZGi0oz3P6WikIL1ikrBquv0Lu8mT
         nWECfKpxWFYkpa5ezwCo3vN6n/h2l2bK8LM152L6ynE/ImghDV+TNV0WqmNtG7dHVIpn
         69UKF00qwJtlLNfroN+7yN6ejfV5PbJfBc68I/p2fkeKnruKusBO4muUYaaP86Y0jTtT
         IwyHq3R2q97A8+TNJbOhl1FV79p6UTMWaOJo85Yy96I1XLaUhnXYPp2zQni0apZqJOzI
         /8vnODAolkVLkVo1ai6E4MB0b9s0NxcM5n1OxU71jXKO8WdxOeKsRx2Nn17Jkww4ZCJ4
         7QAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b74si9068466pfe.47.2019.02.10.23.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 23:35:48 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1B7YjV4119047
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:35:47 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qk4ftrs30-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:35:47 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 11 Feb 2019 07:35:45 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 11 Feb 2019 07:35:41 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1B7Zegn15270082
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 11 Feb 2019 07:35:40 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6337911C050;
	Mon, 11 Feb 2019 07:35:40 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8C03811C05C;
	Mon, 11 Feb 2019 07:35:39 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.104])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 11 Feb 2019 07:35:39 +0000 (GMT)
Date: Mon, 11 Feb 2019 09:35:37 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        Christoph Lameter <cl@linux.com>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] Documentation: fix vm/slub.rst warning
References: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021107-0008-0000-0000-000002BEE963
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021107-0009-0000-0000-0000222AFCCA
Message-Id: <20190211073537.GA25868@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-11_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=912 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902110058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2019 at 10:34:11PM -0800, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix markup warning by quoting the '*' character with a backslash.
> 
> Documentation/vm/slub.rst:71: WARNING: Inline emphasis start-string without end-string.
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  Documentation/vm/slub.rst |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- lnx-50-rc6.orig/Documentation/vm/slub.rst
> +++ lnx-50-rc6/Documentation/vm/slub.rst
> @@ -68,7 +68,7 @@ end of the slab name, in order to cover
>  example, here's how you can poison the dentry cache as well as all kmalloc
>  slabs:
> 
> -	slub_debug=P,kmalloc-*,dentry
> +	slub_debug=P,kmalloc-\*,dentry
> 
>  Red zoning and tracking may realign the slab.  We can just apply sanity checks
>  to the dentry cache with::
> 
> 

-- 
Sincerely yours,
Mike.

