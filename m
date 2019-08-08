Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFB40C32751
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 02:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83AA12089E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 02:47:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2pId28en"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83AA12089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23CF06B000A; Wed,  7 Aug 2019 22:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED816B000C; Wed,  7 Aug 2019 22:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B43B6B000D; Wed,  7 Aug 2019 22:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8FE26B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 22:47:02 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id y198so39938472vky.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 19:47:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lrRmrH7t2DxXhTipWxRRs5ivdb/74vVU7DqRNEZ410k=;
        b=UKpW8sdlwlOeoV0+D+HGHdiOFc5gzqw0j7e3LhlPwZwvDlmCeAH+EaJCR+6RT/hbZ9
         VKi6i+nEvSOGR/6OsnpPiPK6egBKZogziNsEA8Rj+GX97BtdiwaV23xvuzYXb222rDlQ
         F45o9EiLRGwNiEnR6pRIplgQ//GfBdeLFqFzF8kfW5lY0ZABIq4M1PlySI2oTsCZZJPq
         fAB7ngzabD31epiSFdOPBkBV5GEfM1XaUv2mrmdSNJKGVvoMjiNI6JVSxYwZjZot7eMM
         pe+134VcrGEERhbL7yxVhjKgwYmNXaMoD2JYuVdhUYcsOFHVf/IBvHTLZuN8mJk9YefC
         86tQ==
X-Gm-Message-State: APjAAAU/nx3lbomN0EiSy/0fkOzX55ioC3ZocPnSI9LkLdYaxHtFXqqG
	dbnnRu0nQuVzkX5/lHMWZBSRNPfIKsw8rLKmIE5Wu6SpQsfamWTKFh1n2G6qdI1J4W2P519Ol+O
	hkZ95lntfysNtsHgu5j8WBcTu+BwIA8l6ZapDw6AEgUtqBoW2mbQR6Fk0MqzhCMi0nw==
X-Received: by 2002:a67:f355:: with SMTP id p21mr8164679vsm.204.1565232422515;
        Wed, 07 Aug 2019 19:47:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpQuR9Xzv5iGeTngz7y0Pu1Yl6O5nB0HKkNvGuzjwhUIdrPyBPxbQP8LfiKMfvqoZW4DLX
X-Received: by 2002:a67:f355:: with SMTP id p21mr8164666vsm.204.1565232422020;
        Wed, 07 Aug 2019 19:47:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565232422; cv=none;
        d=google.com; s=arc-20160816;
        b=GoV5VmzbpqclbZS2Mr3zKJ145TKzIpcW6TG/aqKmlyNtvF4qQgmkjfxCKVjXYC4ele
         tLRxiJwLlULWl3BBFEjm+5eBl8UpB4sJdzDINJs7FoGsiR/O1wKHQI5viOp+C4zdCJJP
         zId7Uz2uBuJJnG337aq4UfK26D+Ej5uTfgC7Kvj5eQSV+sXjQJS2s+mS4v2KpzkKCq2W
         rrStVGUs3/K1zIhvBfCHlrc9eHxVBwTl+33LEly1PC91quimlTb9h/AAo+loaJNTIn63
         vuO3uKxTtGRai0vCkDsjekzNeEJ/o1jxdPEQomjWWTUubcmTNW92o48eOj8w7cGrZkBP
         zFmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lrRmrH7t2DxXhTipWxRRs5ivdb/74vVU7DqRNEZ410k=;
        b=y4kMlU/Sa2rB+xAuNY9eJ5+GawPq9NtLm63hIhtfpRLKrP4/s8MDBQv2drdkmQtPLT
         VnxCIjCcAGrXTphsOEsXMZt9q/k4ltBnto7hKB3VLAU4EqeFgv/zCyj1syEgdamvRfDu
         /t8Jepkaf+PMDqnnQgPQxqTMgJqqEXWOXX1EHsB656RvbtESdToIdjHQeI3rBwVPN/0Y
         m2kUIH4FYBApA2KxxlSjQxyvFsqw8xQXhtdhzqAtKhI3zUJrg+ywhFnkaVOYaCnlqacg
         1ogUcjvInndDS2Z4IIHBmp97ZXh1/RucXXIJX7ZoxweNvCo1MEK9PF/nTTO8eQ4XwP8X
         cG1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2pId28en;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o8si18621261ual.62.2019.08.07.19.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 19:47:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2pId28en;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x782hvDB102089;
	Thu, 8 Aug 2019 02:46:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=lrRmrH7t2DxXhTipWxRRs5ivdb/74vVU7DqRNEZ410k=;
 b=2pId28en9LJEdW0ne3zijEyIyY48YmF3imXfi6P2+oxCWtdJ6n6EKOllE3HNkXrr5Cgp
 25iopFMtfd8J0PeGIJtZLoIgdPA2vGVWrxRnsqRfTfcZglqLzSBICsThdvJrL13fq4/T
 aVshbx3FtGdJ0sIGAQwpJ+wJLDwFPgbaZKp0HBsd7bTk7gyQZ4c2Up4Ap4MqZEB+VrpF
 iTmbzXtzX4OkI2a89ev0Qhj94GjIrsftZtwlv+F7/Qt9fszW46aKfRRnKD5t5l45CN7w
 gt7lhpfWpxRuPcCTPjSVX0u3RXC+7j3W1N3okx3TOm6xL2RQGPktKh5qu4Dlq4kpZkqk ew== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u51pu7u5e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 02:46:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x782hJ4C173010;
	Thu, 8 Aug 2019 02:44:53 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2u7578hr6f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 02:44:53 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x782iqqv010401;
	Thu, 8 Aug 2019 02:44:52 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 19:44:51 -0700
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
To: =?UTF-8?B?6KOY56iA55+zKOeogOefsyk=?= <xishi.qiuxishi@alibaba-inc.com>,
        linux-mm <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, ltp <ltp@lists.linux.it>
Cc: Li Wang <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Michal Hocko <mhocko@kernel.org>, Cyril Hrubis <chrubis@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>
References: <f7a64f0a-1ae0-4582-a293-b608bc8fed36.xishi.qiuxishi@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5f072c20-2396-48ee-700a-ea7eafc20328@oracle.com>
Date: Wed, 7 Aug 2019 19:44:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <f7a64f0a-1ae0-4582-a293-b608bc8fed36.xishi.qiuxishi@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908080027
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908080027
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 7:24 PM, 裘稀石(稀石) wrote:
> Hi Mike,
> 
> Do you mean the similar race is like the following?
> 
> migration clearing the pte
>   page fault(before we return error, and now we return 0, then try page fault again, right?)
>     migration writing a migration entry

Yes, something like the that.  The change is to takes the page table lock
to examine the pte before returning.  If the pte is clear when examined
while holding the lock, an error will be returned as before.  If not clear,
then we return zero and try again.

This change adds code which is very much like this check further in
the routine hugetlb_no_page():

	ptl = huge_pte_lock(h, mm, ptep);
	size = i_size_read(mapping->host) >> huge_page_shift(h);
	if (idx >= size)
		goto backout;

	ret = 0;
	if (!huge_pte_none(huge_ptep_get(ptep)))
		goto backout;

-- 
Mike Kravetz

