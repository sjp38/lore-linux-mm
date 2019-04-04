Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 283E1C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 11:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE174206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 11:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DozJfNIH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE174206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F97F6B0005; Thu,  4 Apr 2019 07:42:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380356B0006; Thu,  4 Apr 2019 07:42:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2250E6B0007; Thu,  4 Apr 2019 07:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDA7B6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 07:42:16 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id z130so1758849ywb.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 04:42:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=jbJEzY5BCNujrQFI1tzVCWBB1xu17IwUc3TgrIl83KM=;
        b=cYIBLysO6RTSe27Be+mRz/tQWQ/EMBGVOxJyzrbsEYQyalTJZ9KC2ZEsO0ivfREnNg
         0LKKzFvpPlWQ+7iYAvE5lGgVy4fPN3adxzvGLFdP6ntsC2zxm5cAIglg8R1fB44lFu4S
         HRaf9qqpZl4Vht/W+RnRzLmRjoSujvoVQBFLk7JAw7cNqCdNe26yrIPz5UnpeWs8yMjb
         mae5mO+WNRw7OEJdGFyY/vLafs8FSBr+6TbOFLTl1aQM72+NI6L9bIyhrfoVBjnR+KQd
         vwRf2LP4o9gBtxqzoKnIeoJCFbISt/OtA/1O7TTG/N5IGSiLsCnCB9sZVogzKbRpO3IP
         EfyQ==
X-Gm-Message-State: APjAAAVfSqQaHNPU7xRWjU9XAqa5xbzo309EtBk0Ss1/vARdrNsw3gmY
	gdWhS9P4x95ZKA7utpXfC0Pf/own98eM79rLQI2CjsgLN/PS4un/SoDd+DTT+pQKMsZlG+HaMAs
	exRc5sobI8L0txDYyGNZui7YONPBWOdS1Im2eKwUWMGQnNEO85qt2P9g7X9odcHpT8Q==
X-Received: by 2002:a81:730b:: with SMTP id o11mr4149654ywc.365.1554378136584;
        Thu, 04 Apr 2019 04:42:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfXAz/CGnqroHm4q+lsbt+e+mPfAionivYf0YjXNhu05pZQlHQ12KM+0DK+YaY/KRpIrQ1
X-Received: by 2002:a81:730b:: with SMTP id o11mr4149595ywc.365.1554378135655;
        Thu, 04 Apr 2019 04:42:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554378135; cv=none;
        d=google.com; s=arc-20160816;
        b=otWkTtMxIDqNGBoUO746ZveydSGlc0kNMdJz0NkXQ2R1dR/FXNv177XGc/4uWtFBvx
         oVP+gu7/CiF8cF7BwK39fn3xFnAf7XPZYALNirU7rC8iSUZm4cw6kBQqK6q4xVA2APmf
         7DQN6OM5bVFkXpNTl0Ismlw40Z0DzLMNPp0+z9qHZoEWphHamKgumynI95M/H5WWsEfW
         th45N61aDTvX5LAQvfhObnj6qHN0KGuIoej//JlU+8tG6ClbZiJ6710Zy9dPtY9zOiiV
         aADhDn8Eo9emfMYWFLUmDMco6u+z7hM3rmB+fd8LtAyvP+W+XllDjUD/71A4X44ajrzQ
         Pj3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=jbJEzY5BCNujrQFI1tzVCWBB1xu17IwUc3TgrIl83KM=;
        b=WG0AV3Dz5giTvxPyulEpGcnSuW4MNWVuZONVZPCfzdXfIXz9eAALaLGJIc0Fj39OGQ
         hmbMigCUhEB58cB5cecrN5SG2wv4yRzdYshtahwgaNjDh2tjEVDTG7hA7TE98FsXwlpC
         SidtjujmVhkgjiyRDmnu22N5kXTPKdhpdDbYLrMrI01f8GjvQZb0PHri7sMzHZ2pSEvv
         ZJ3Tb+7/T1XKVIAAEo/B72f7wsWVSsSedx7iFrMACLngqNLICWZUHF8xMesBsbwMbmkB
         QKPNN+qGIAf2z/doftAIv1lWxviggRUijthTiY7zZ8SiK/xIRc5EVl4EPA2ZESBmBG+1
         EX8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DozJfNIH;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 186si1688408ybp.62.2019.04.04.04.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 04:42:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DozJfNIH;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34BYKVZ030419;
	Thu, 4 Apr 2019 11:42:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=jbJEzY5BCNujrQFI1tzVCWBB1xu17IwUc3TgrIl83KM=;
 b=DozJfNIHS1g7UJ6gnP/Es6wmVS9gLj6ZIc7pAqqH3xe4DQrb2mBFoWdqZd/nx6xOqjAM
 4u9BsnKMbwGgAUI3H3B5VGjH4ekUJPPDF1g4ZJOs6Taq3QOARaR1fRxe2ot0U0o4MfUZ
 otUK4ceUt9JCdbQFiS+YAdL9Swj1sylXXnpmnm24Xxk5PC3A5JfkYlc54RtH6WHMv8D/
 2074EslmifUcHXJ4U/9AYKpvNIlPqU/IjcbFiQ6k8LxCitYANpsPSXRRpLGEnEbbuuF7
 xfv9DJ3LqgS2M/hkoU+ueM/909rPZlLzK2YRhc5d73mkAyqve/HKRXQgzRhBjRGwX+vY 0A== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2rhyvtejbv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 11:42:11 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34BfdIi067706;
	Thu, 4 Apr 2019 11:42:10 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2rm8f6kv7y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 11:42:10 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x34Bg5VI029571;
	Thu, 4 Apr 2019 11:42:05 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 04:42:05 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH] mm: enable error injection at add_to_page_cache
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190403152604.14008-1-josef@toxicpanda.com>
Date: Thu, 4 Apr 2019 05:41:59 -0600
Cc: akpm@linux-foundation.org, kernel-team@fb.com, linux-mm@kvack.org
Content-Transfer-Encoding: 7bit
Message-Id: <E1E9DB6A-FDDE-4930-8F50-B01B59A5E208@oracle.com>
References: <20190403152604.14008-1-josef@toxicpanda.com>
To: Josef Bacik <josef@toxicpanda.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=814
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040079
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=863 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.032094, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

> On Apr 3, 2019, at 9:26 AM, Josef Bacik <josef@toxicpanda.com> wrote:
> 
> ALLOW_ERROR_INJECTION

