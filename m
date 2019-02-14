Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2DCAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 18:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76BC521B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 18:39:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76BC521B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7C508E0002; Thu, 14 Feb 2019 13:39:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2D4F8E0001; Thu, 14 Feb 2019 13:39:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1C218E0002; Thu, 14 Feb 2019 13:39:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B67E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:39:10 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x134so5420151pfd.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:39:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Z/c04WIYVaJ0dTpkvWrCyPOP01jGX0WKjBkYpk40CB8=;
        b=lzOlbbbB//Bft6FsOngeDO2oZa3edB7OaL7baZszzJWLDHRD+fhzTet4Dkhqm6pYbp
         wswBpkjc6MTP2CAIdhu+ROJaocRMGudfSgOryy8bISNhawPIStw5t3lYsF+EXdKlgeOq
         sNz18D04XsU0SU5l2QNqGTm+g98UqSPnbjzO7MOdLdgMCYUwEchBOgLy+NyOnqY0nUcQ
         l+uPfDdF5IVRngMMTTt3GoYDOrVEPVYy9JmBjN4SkDE7cF2KWzKLLZ7z5ykmD20KRXun
         h8SPhP4LpoVnwk40JTAmbusH1LPyLbvHizWPQKiTzD5M0TEXRTeqkrgxCd/7X9hwuCMT
         /0KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZLBZdszb1esleXhurzyK1e1VADP/cCAm10iLt9hbruYtlMBlRl
	9yilX4ubs9M0nxjgTFLEx24edQcK+3I0LlWlX/z9zyAsH0wfeRsztf7XMxCHjbWyDuKrG40i9aF
	dz3qNgY2KZ2V4en9H2JRYRN7UrQgWTLfwPPeon3SI3wP3Wav8s7k8yb4IARRODQmKZw==
X-Received: by 2002:a63:c345:: with SMTP id e5mr1259241pgd.103.1550169550269;
        Thu, 14 Feb 2019 10:39:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJj0/fAXrn0DVhYHOiQdFh1YkSqMtsWfWRzeI7UHtOTSfN/kKndHoarttvRTs1+jpiRAX2
X-Received: by 2002:a63:c345:: with SMTP id e5mr1259188pgd.103.1550169549402;
        Thu, 14 Feb 2019 10:39:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550169549; cv=none;
        d=google.com; s=arc-20160816;
        b=cxeh84aayiE2/zrCyvNBZSxxgWiVGZ+NOqjQRkgfrm1aR0gL1hZ47mHFjsYV8yI3o2
         rs3NsMveZGPmsqGFfQ/JUGnWyzzj78eZrio9zaMWvyUpB9ZL5Nh8KvwI8jFD1E6h7Nrs
         aMElTG83PvDC9I9mc4aGiOMSTqKSf3pNyu5bbG9CLiNfwZM2kbFtY5qqaeA6vRGcivP4
         udzp+BSfGIeuHUSot0TMlnGq7mixcMIrEFxz6udVUNinyhWCE8SfNXKZmJ9W+abTTTLn
         26pARC6p3v045TozyN7ioOG17eWm8a2PGLCAAfdzt1Ei49+X9YL10wNZhky+viS5AFlU
         G31w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Z/c04WIYVaJ0dTpkvWrCyPOP01jGX0WKjBkYpk40CB8=;
        b=UHNV0aPmuL+59rH89W4/oesRl85u4bscw9allljMi+nB5qsluyA7NWjAve/892SP1o
         IPyt5sc6gtSEQoT2Y0KHmCDcQMbtL5bUhubdjFmmVXNmEA3+ez00ZRWCOLUFzziSUsye
         wie8vHuW+pBcoEF3PN/3z/Lc+8drloYc/HI/KlzRwHuBVpwvztkkcPOatws4diLRIWLT
         +B+g3CKdFDRfvtik1+wGsd2bsprnfQpnJLb+oZpvagq2ZQqBafn6n5blHXb9diNBdL1J
         vi0kqe0YdfmtjGM/me7fb/zU/QqQ3E7wTXN3i/l4Aov+oMEWx4sf1BC7+cDH/GWzOHya
         /HyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g187si3056656pfc.43.2019.02.14.10.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 10:39:09 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EIcwPP121909
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:39:08 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qnbxuyqax-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:39:08 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 18:39:05 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 18:39:02 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EId2d92163186
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 18:39:02 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DC84BA405F;
	Thu, 14 Feb 2019 18:39:01 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ADF45A4054;
	Thu, 14 Feb 2019 18:38:58 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.8])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 18:38:58 +0000 (GMT)
Date: Thu, 14 Feb 2019 20:38:55 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Palmer Dabbelt <palmer@sifive.com>, Richard Kuo <rkuo@codeaurora.org>,
        linux-arch@vger.kernel.org, linux-hexagon@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-riscv@lists.infradead.org
Subject: Re: [PATCH 0/4] provide a generic free_initmem implementation
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
 <20190214170416.GA32441@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214170416.GA32441@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021418-0012-0000-0000-000002F5CEE3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021418-0013-0000-0000-0000212D4D2D
Message-Id: <20190214183854.GA10795@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=736 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140126
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000062, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 06:04:16PM +0100, Christoph Hellwig wrote:
> This look fine to me, but I'm a little worried that as-is this will
> just create conflicts with my series..

I'll rebase on top of your patches once they are in. Or I can send both
series as a single set.
Preferences? 

-- 
Sincerely yours,
Mike.

