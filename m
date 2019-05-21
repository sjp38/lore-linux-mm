Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 607D9C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:53:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B5662173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GtdEhsmE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B5662173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6C8C6B0003; Mon, 20 May 2019 21:53:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1D856B0005; Mon, 20 May 2019 21:53:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0C2E6B0006; Mon, 20 May 2019 21:53:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8205A6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:23 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id i7so11258267ioh.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:53:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=yVkvZ8fXUaw/jTaRiqp6doEQkt1RyJ1CKsPrkEb5+Mc=;
        b=Sw5zjBU35WErfKHqLQzm9DGeYSCCMsSxEyIYPmdoODD8OlN61MksPazNGOoMmUKQfv
         SChvqQraAiXE5gIb8CSTcEq0mA1uTDZLcuamW5kCX8jW2pXw7JZFMVZSs3EovSK+g20H
         XMzQdB8V3sajlwi35ZDJ8D8rtmcELTChN2LYTRpKPIFTI+S37pVUx3X8+QbDNwHbHaav
         Ga5a93r7xB0OHVE2QOXapBRroOnz6QzLCgSQaB+KnyxaoQN+XnTh7qtNLLJPvj2FgdBI
         XhKVJmQC0Fk8Lf9K6efEyjkZHUF0SupaJKza4fZ5BJudUX0gey2vPj3iW1Rg5g/sT6YA
         nyuw==
X-Gm-Message-State: APjAAAXflsbtHEWKDK70ti5WGPIvXnc2n1mR1rkA/CBwtl8+b5MfGKl9
	D/p0eSq3/vLapmGD1+RSCXfvxD493SJ4lE+jCMUNtOmhXRp2eqjNQO/6R3S7xqcOhBVNmApIa4k
	1YdFQLWxg6rWBTqViYk7qDHqos4hFQcOM3FiQ+jjkVzo0yCty47WldetC0DGjwremmw==
X-Received: by 2002:a5d:9948:: with SMTP id v8mr19793605ios.190.1558403603341;
        Mon, 20 May 2019 18:53:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvJiKfpuayTIgS/4UgAWQMxNC9bkA8j2iyj/XMEzwHRUF76Krva9LNWIi3QUfRCkrugi00
X-Received: by 2002:a5d:9948:: with SMTP id v8mr19793593ios.190.1558403602890;
        Mon, 20 May 2019 18:53:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403602; cv=none;
        d=google.com; s=arc-20160816;
        b=riCk/DfmsZht8im7hfaR1DMbw3BZFJmBRvevTzLHsQTwkHKSokX+y0eqp7mGgJflax
         elabpxRSpY6iSHKSLH8VKzk2zAUvROq+MzYhTecU3ezyJnPpOhhtScxCee9JNLB3xW6z
         6AgQ9MzJrFbKQUa4R4PFWXkjQ7g1veLsQL/p3qSmy+j+xfon95tC/Jo34Y0XAM+XE8od
         Y3//21v+mxYCmxaEHDi8xmxsaZefFzQKYSZ6lsHm/SG6uIP8e2rO2dR8frNC4RCszw0/
         bmQ9CDGEp/vzdLkYvKBHofwiOhBTxYQ0pCw+y2dvKK9fhbPKT1peZvPsPgZr9JWdQbHL
         Uztw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=yVkvZ8fXUaw/jTaRiqp6doEQkt1RyJ1CKsPrkEb5+Mc=;
        b=TsX7yeNmAoaE58qrCbTBkd53x9wNjiB7FRck/VRrZENKBTZyAzAo4FG9YqKzIbpK9G
         SqlFJ8eNcrFizB1a/RsKe9jp9aJoPDBWBt8/xwSo7bLf1zBRdpMAW0p7ydbSAU6iB5D4
         RYKW21y0TAhN5K2Ojute2g7vdIQG/TA4ZmMTSiKryPXPu9ome6wrfVSpn4ymnY2nhsYk
         Gpt19Ejf9El/1TAZQm9jMG9BcvcwH1axBp22szSks+icva0o6QMvEZEPO9bWMIN8rwos
         r+0Uk4FIPpO8EumYXFgLqNIlgv6P+FpxC9T3YQHMqMWuPd3KoeXF0f0JA7QZs4IU0qcO
         86fA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GtdEhsmE;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h6si11411424iok.129.2019.05.20.18.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:53:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GtdEhsmE;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1oQ3S041273;
	Tue, 21 May 2019 01:53:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=yVkvZ8fXUaw/jTaRiqp6doEQkt1RyJ1CKsPrkEb5+Mc=;
 b=GtdEhsmE9R4Zp5z5vZMf9BbUL5SfV6BWLtuTdxklSLGncygnasVo0c0idEhjz950KX2U
 BBQDdYFcF4q0kwxRhRiahcfDSy01chn+f/yI7aH7kB0wAAagAmRFbx0J5gyrqUkIYLJG
 xicAQtlDBoFpB7eujyAEG/d8c20PrPGfYBb1JqoL3s/50G6dlo+5STLSNi49LosJnOcY
 d8Tei/znbUWFLpq98487U3WBOWVJufze2kfUM4w6gnWij383V4nzLeLCUEsSOp3iW8Qv
 0VxNjmPohLFDyVK+zJpEcc+Ui9xwFv/6y2IzdmfYc1F5AU5rMwEq3aAszVy4BIpIYal5 CA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sj9ftabyj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:53:17 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1pSbK035907;
	Tue, 21 May 2019 01:53:16 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2sks1xwx3e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:53:16 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4L1rG5A002361;
	Tue, 21 May 2019 01:53:16 GMT
Received: from [10.159.155.76] (/10.159.155.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 21 May 2019 01:53:15 +0000
Subject: Re: [PATCH] mm, memory-failure: clarify error message
To: Anshuman Khandual <anshuman.khandual@arm.com>, n-horiguchi@ah.jp.nec.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
References: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
 <512532de-4c09-626d-380f-58cef519166b@arm.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <a2be5833-2161-38b6-2569-46084207ee47@oracle.com>
Date: Mon, 20 May 2019 18:53:14 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <512532de-4c09-626d-380f-58cef519166b@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=944
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905210009
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=995 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905210009
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/16/2019 9:48 PM, Anshuman Khandual wrote:

> On 05/17/2019 09:38 AM, Jane Chu wrote:
>> Some user who install SIGBUS handler that does longjmp out
> What the longjmp about ? Are you referring to the mechanism of catching the
> signal which was registered ?

Yes.

thanks,
-jane

