Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6186EC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:31:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E2D62067C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:31:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="k7VDx2RJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E2D62067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7ECE6B0006; Thu, 25 Apr 2019 19:31:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2F6F6B0007; Thu, 25 Apr 2019 19:31:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FA9A6B0008; Thu, 25 Apr 2019 19:31:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 587B86B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:31:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so739680pgs.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:31:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=waTWw+kcL/HdEyMs/PKQkW1VcQyCyLTnQ9LBeYK9jt4=;
        b=O6y7EHOT9snvdktzFE5L5tcTPsIMysQUOX1DUNKuDOqaUq98wM1GSh2uuzjORsq1m8
         lo2QHsiGgx/zsCzYvQXbdCpY10A1ZaBuKey4MUu4nib5A3tuVaGghQ0PvdDMw37TTnwf
         EbE5qRPS1981ZVfECgoWNxGuxH03xSRBSCF+MjOf+9zRO8p7955gCImhAVL/C1Zql6CO
         fkvqcVl/uPRbt6oSdN3kf8JziPbmQNyOlHt0aUaqcZVI2rCSqWFDel1jLtNt9We5EOL+
         vSoVqc4M4RuJbeObHbwiNnXV78Ye1p9gCsm3AxRX43Gkzm3HEl90lQXDiTlHPdgmOKQK
         pbjw==
X-Gm-Message-State: APjAAAWDQAqfUi0MuvEvRwXw0Abi8ZLAIcYQvHu0RUN3zhBJuWX/arDz
	lngydi1D2R2ACR7aCbyWxbpOyWzWCamfNOutVV3JQ1Gehm2QwU2UM1HBWg7tCVEToeYeMevxtR/
	tTbGmFqkaucj7uOB4CIulBA74B0L5jehdeA8hQG/pzQEDC097mvIIV+YflgodTynFnQ==
X-Received: by 2002:a62:26c1:: with SMTP id m184mr4159167pfm.102.1556235114050;
        Thu, 25 Apr 2019 16:31:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk9pIGAhkglZ40Tu4U86lkeFRt73yVAHIdm+Rq8by72D0NxMh2+VhSj6TZL6f3ctq9KacN
X-Received: by 2002:a62:26c1:: with SMTP id m184mr4159108pfm.102.1556235113385;
        Thu, 25 Apr 2019 16:31:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556235113; cv=none;
        d=google.com; s=arc-20160816;
        b=ubz45K+ZAfaf7lUk2reVxYa8egq1b8T+nsU/xNIC1Gi1j7h6bLAuJXFubF7ICrDe3t
         nrVR5+vSw206LZVgLT9aCvAf/hyRZyJVq59b7EK0AXeyMsT6a1vvu4ggGX+hdiRRWXuo
         dvcOJwjjkKwxvBmT5TFYP3CFMdM2eQClSYc7tvKeVchoTTX7NxVxPHQmuo27/9poC8hX
         igDPW9giTshHDG6sj0uoqcmJ1oRWG4QeOJ27UK+SzRvBTBPuOtPOG3ogenzLC92nrt4b
         AAY8dRh5pbu/Z7L9Fyz2ksouUpWtokh+QmJ2JWami7gPn/a9+3cvOjUBlgo1PJMzJGi7
         oCDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=waTWw+kcL/HdEyMs/PKQkW1VcQyCyLTnQ9LBeYK9jt4=;
        b=0cBohdl+JpFZRJTfHkWmQYJBDc/Tv8krF0e1lsVvROfqAtEzgpEgNkiwyuNaWOrPU6
         2DgDo1BegY0vNcu7iYZDxalIClIHNYkHz+vT/hqYEfOw1RutzDZaGZivqZIq5hSBLGR5
         PrpOkocAzKqdtDFw9bFJMrPgmZuYNTfsWHBGn8o/9YAzxFwtAfWhDekKJK50wIoyEKvP
         V0QmqNNx4tbp3BBOq32riDL45SdKGTC4Omm+/KW6TYn4GQpeSB94YhtKgeX5NOJlCstb
         /euUIHpMXjqC/J+xjh6Ka0MfHhJzn5bwnYPuhC39BgGe2Igo96IqF+C27q7KrAh4WRwx
         bUmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=k7VDx2RJ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id ch12si4177498plb.5.2019.04.25.16.31.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 16:31:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=k7VDx2RJ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3PNOXWd035390;
	Thu, 25 Apr 2019 23:31:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=waTWw+kcL/HdEyMs/PKQkW1VcQyCyLTnQ9LBeYK9jt4=;
 b=k7VDx2RJxkZAkqeAQLCPZfzvvuX8twqxU6YpvjoeGrU6R3y6jiKkQ4HiwaMdKGnnO1Qg
 GO8jq2j0mMWElpFgZMSV9WGF3qVJoUbvdJxSdbadS6VwGAN5QXz9qTC2bUTWMXSceS96
 oiaauaMsjTxNTEiUT5oQuEeagzUw7mxc8CDFaWCLkiaaMgDOqYk5mijfzXaTp4vj3RqH
 zwBXmPkGsuI9vqGIW0xOVqMEyu/bcMwjXBeQjVD+wUsWbWYc1T1ICjZDICR9u9c/Klrq
 Nzi04BXB9HyETu8xOWl02jsCxd4eEgeSAT6saXYa/t3pQ9ztKohvzO/xzeowyRbLpzai 5w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rytutb835-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 23:31:45 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3PNUWRB168756;
	Thu, 25 Apr 2019 23:31:44 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2s0fv4f7rv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 23:31:44 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3PNVgff025335;
	Thu, 25 Apr 2019 23:31:43 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Apr 2019 16:31:42 -0700
Subject: Re: [PATCH] docs/vm: Minor editorial changes in the THP and hugetlbfs
 documentation.
To: rcampbell@nvidia.com, linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>
References: <20190425190426.10051-1-rcampbell@nvidia.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0551948d-1aa7-273b-46ef-ff66f9ba64d4@oracle.com>
Date: Thu, 25 Apr 2019 16:31:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425190426.10051-1-rcampbell@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9238 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904250144
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9238 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904250144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 12:04 PM, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Some minor wording changes and typo corrections.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs_reserv.rst changes,
Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks for cleaning this up!
-- 
Mike Kravetz

