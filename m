Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34750C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEB2F20882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:00:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QG8HzlYV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEB2F20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0F88E0002; Wed, 30 Jan 2019 06:00:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 391D18E0001; Wed, 30 Jan 2019 06:00:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25A7F8E0002; Wed, 30 Jan 2019 06:00:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D37C38E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 06:00:11 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so16547283plk.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:00:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=61scKswmPbnHoOk96Jf+ol3O9mYXOld0qByaXCb56ns=;
        b=ld8EwNJRJ2nllSgiiO07CnhC3oO/J+n2CHds+hdaDeoHTXdTGw7nl/yQQlR/DrtNF0
         4dqjctg3uqAZqMeVmCt1p6d24Yr0KyubqZqX4yln3Y+m5Sg0FQHMdvp5AHEbFGnKryP2
         XOOTfek2nfFx9mxm/v+yvBao/F/ahsBX6jkzWVDO3dcelxcXbxMM27e5ms5To+U5Irxr
         5QFgDcg9DE9a6PBHiO5o3yt+Dg7PXyDrCWJiUOWlHiS0hGo+gjDaGD5V2eN5myxuJRkN
         6MFNrVL5Js0JZSh2So7ZjzmJUXrj75TmnXXoq3r27y+je+vrTkbBFCwSJLi/pbmt9udL
         BbGg==
X-Gm-Message-State: AJcUukcaz0q5mbyGwCNmTlUGI/bxnEBQ8/M0JhOMpBt2cXxd9EAk55At
	zfZ6lrXpwdqrfZv5NxJ/B2z0+2//tRqnBApkQyqLVbPTRe60aKZRSsGTzGb9QXT0z4iN3UN9Wdz
	HM0asi9dMHUCLSHGK464g4J1GPAVxuoWLxxdhR1nlW+eeQm8beM9ESVy8uPaJLn6rOg==
X-Received: by 2002:a63:dd55:: with SMTP id g21mr26574235pgj.86.1548846011443;
        Wed, 30 Jan 2019 03:00:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6N7wsipRNTuTwDEiw023S/Vxx0gxYxa7HvakLFNPJp5WTQykQNj2ZKifqjWzeWpp5gMcu+
X-Received: by 2002:a63:dd55:: with SMTP id g21mr26574196pgj.86.1548846010705;
        Wed, 30 Jan 2019 03:00:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548846010; cv=none;
        d=google.com; s=arc-20160816;
        b=IHm1l2Jo7LIv1akJz4GGPLCEhaQp5AAYS9X5hvjzVt/+Is91eET6HB5yt7HFRD4Fbg
         /VkroxEZTdDoY2GWun2EX199kHb6U00s/YXuKDnGhnfCrnHDSg+8t+uobRSwP2LTCFdr
         R842UYyqC76q9qVjJqFTkIeqi0wodc8sT/cI4vv+AgDcvWMKiWkOibGTPlL/MYq4dl8y
         9RHY+99NlyiTURyic/80GUzvwgf2IMDgOrNaD4ipMbw3i/QLabeQ0qX0T9m1SqlXsL1C
         arpPHIpupX1Jy3giYMSzktrwm8vNZhJZcXWuRAEBbRxPe17pLOoGpmfqfMwUjTXvBdeT
         9YkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=61scKswmPbnHoOk96Jf+ol3O9mYXOld0qByaXCb56ns=;
        b=OfQuJopO+pHCkGba2v8zjOGCg28r2JPuYMJ76t/e488TZ/JVS/mhw+Ee4968207lZS
         Sh5qtqMRP5v1FvpAAfyw5AJpJz+jAfb4cjLbBOzAeNzcX++7CLPqOyZ0ii6OHG8LFbGL
         uiKpWFCVEN28g0ZHNJHmpJylZZaJ/j+1LFWlJhzpHyq5n6LJbygkK6DpMKWQA6GAuWNK
         fvOVSVAmeU8LBA1QuyHf0+zJJaqhvKvHU7NVt++Y1z8JPEirpq5HvW2Bx9gFnlIRBEGT
         dB8shvabbS6hrAQ2pg39jDb544su3ODRXvOg2HeS+Q/41TCM6WOMgfZki3FIoiZ/He8G
         sXXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QG8HzlYV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c7si1232128plz.118.2019.01.30.03.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 03:00:10 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QG8HzlYV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0UAx8pi116005;
	Wed, 30 Jan 2019 11:00:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=61scKswmPbnHoOk96Jf+ol3O9mYXOld0qByaXCb56ns=;
 b=QG8HzlYV9F4869aLEYwiGZCj/XYcJ4bTZiDrFGX5sK44a5Zf1BdNzdsaz4JEvMET9MWv
 ikUK3ydrtqcO+K1hGtf+3zWFc9Twh++aj+8BCzAKOx1pD0rQpIxi7GyFzsdqQavxUBMN
 VZEc5HPBtR/ztMu5TqjhBQ5DnHRViYYIwUxrRbh/dsYB4+Q/PjUnfIEXMpzUxr+o72Xk
 czFgx8MdEjO75dQe7v8EnSEQG3uBIChHnipFJp/oKaVk4krpHBdsfNttLkkj0Y4ahVju
 RARxxh4ov7jkEpbHv1Bgv/cwPBpQpKNmrqG/lwN+AuhWUqjmAaEGtCcep3lecxR+GF5l Bw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2q8eyuhukp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 11:00:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0UAxs9s014114
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 10:59:54 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0UAxrmi028591;
	Wed, 30 Jan 2019 10:59:53 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 02:59:53 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.1\))
Subject: Re: [PATCH v2 2/2] x86/xen: dont add memory above max allowed
 allocation
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190130082233.23840-3-jgross@suse.com>
Date: Wed, 30 Jan 2019 03:59:52 -0700
Cc: kernel list <linux-kernel@vger.kernel.org>, xen-devel@lists.xenproject.org,
        x86@kernel.org, linux-mm@kvack.org, boris.ostrovsky@oracle.com,
        sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de
Content-Transfer-Encoding: 7bit
Message-Id: <C4A55B5E-47A5-454A-AB90-AB52DF42CD88@oracle.com>
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-3-jgross@suse.com>
To: Juergen Gross <jgross@suse.com>
X-Mailer: Apple Mail (2.3445.104.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9151 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=753 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901300089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jan 30, 2019, at 1:22 AM, Juergen Gross <jgross@suse.com> wrote:
> 
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +			/*
> +			 * Don't allow adding memory not in E820 map while
> +			 * booting the system. Once the balloon driver is up
> +			 * it will remove that restriction again.
> +			 */
> +			max_mem_size = xen_e820_table.entries[i].addr +
> +				       xen_e820_table.entries[i].size;
> +#endif
> 		}
> 
> 		if (!discard)

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

