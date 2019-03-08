Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC7FAC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F79320661
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:06:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fC6oxcMF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F79320661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 202568E0003; Fri,  8 Mar 2019 14:06:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B17C8E0002; Fri,  8 Mar 2019 14:06:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0531A8E0003; Fri,  8 Mar 2019 14:06:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B279A8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:06:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id z24so23080458pfn.7
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:06:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iNw+1Pkhe5J5ZGLMUPt5A+xkhv7bHoIoSqlJ28oJklA=;
        b=mKICFSQ/j4mzorw/mCGWn/wwUrsd4vZMId057fFAjj1xdKbj1By+/KK+RPiYOhQ9i0
         xkRdlUunP8zL7yeQuG9L1Zl9IgeriwDwXUslqkeO12K6GP14DuUwsYtkLtKDd5rdbIL9
         WAzhTymaN5qNyI4YIduzkGAL4FnI6eAc8tbsk8Pz8VAmFq1t5lzSVhvpJ4XSQC8haY/h
         z4aEIbno1op7luggkdafLPDocgXUXezI5vBkZ27Z3/fJvtLGGb1d6HMeVj7TvEneMyB8
         oI5jUhOqpbyBWt5WjT+go7bVL00ubTBUlwja/Bls8OdHR2wKjkSNU98FUM3ObELRDJoP
         QZlg==
X-Gm-Message-State: APjAAAXPr/WLRle6bly1EqpfrkXJT2J0EtYoSFJ+YDaKDfhHTq46pKn+
	Gj3VMGXfv+U+u4Hf/YdxxE1KqSTOp5zgZIrLCxunSUXsjvM2XL6N40vn4lSHblgsOVSY4ASHdNp
	5JMUNAGUtarfHLrXldF9v5TrJRh5JoUb6puJvLldpa0O6GlQ+7hOsfhuah0N96Og1CA==
X-Received: by 2002:aa7:8597:: with SMTP id w23mr19532445pfn.87.1552071981284;
        Fri, 08 Mar 2019 11:06:21 -0800 (PST)
X-Google-Smtp-Source: APXvYqwVSdaJMKjpL29F6uSkWZHfCy5Ble7y2P7+CvikvdLS5AqX/RVU+8pq1OlfcU+gHwXBoz8l
X-Received: by 2002:aa7:8597:: with SMTP id w23mr19532366pfn.87.1552071980306;
        Fri, 08 Mar 2019 11:06:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552071980; cv=none;
        d=google.com; s=arc-20160816;
        b=ShC9LcngDHv33EBAB/3GaMAbz5NzRw3Fxl0Vc/C9pOdlE+vOCrIJV3+7M6JIAsDRW4
         pHmk9pNSrnosjHle80vlhqp4gAIqf6TErYVb0JrfVaRXD/V+zw7bBSSiqj4T5IwjutN+
         3Ju9wHml71DIfQTCm5Hgd4TnPbT57L7rHyuO4cCK2xiIrh0F7ZdH8WDMNgYfLcSLoe9i
         Zzn/+9/oYEYMmQrJOqvSnhb3j0frvxC8scQNC8IQi+ja/D2PgvfvBAzMyKKjoMil4KOA
         NUBFq2WKM49e+FW7MdaCPJPCDui8962Pv9bA/PEFDDhc90zgLD8Nr35QGUa2haHZHEQ9
         lBcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=iNw+1Pkhe5J5ZGLMUPt5A+xkhv7bHoIoSqlJ28oJklA=;
        b=BrKzt3UGTC4pHIQAODrjZ6RgGgQeo80oBmTNz0HgSUBB/74Qib0AKvBHXCsPLlIoVi
         5uUwdQunEu4pIG9RE/pEfN9jn3HK7nxuoBOy0jEaKClUxBfmGdr5tvKFK7rGBbaugD1T
         vUEhoT+1bVHXXOh38W95HKxGqblfnpJOaN+wjK6jFSROKlYxj4osA4/bBTwxfryxk37F
         fo9g9LImW8TYtOe39Fmr6pqQhPfShuLODrW1CaiIrSQ5mkNeWWIxPvs3u30bpqkclPWT
         4h41e+SLmF6OIplfti5zbwBr3Jc3gjffcSq0+jCQNMYnxWJ8eK9dcto7vOUQUYyYVOdl
         GYYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fC6oxcMF;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t1si7424095plo.371.2019.03.08.11.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:06:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=fC6oxcMF;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28IxXbi076674;
	Fri, 8 Mar 2019 19:05:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=iNw+1Pkhe5J5ZGLMUPt5A+xkhv7bHoIoSqlJ28oJklA=;
 b=fC6oxcMFe3aedswwYjUt3YGCRHcTEApkEJ3pHGxc7CBgzbQZWAgx6C7QL12S6pFz/kBN
 W8eVQ3L6xRc2eWZcfrY85ztNWdbet0ezZ6qqe4GyV6uoSeQn9TxT10biMLAtTis3bePz
 l/SSypmfrYDEVC3RHqphEKUeRw9XBh7fxqP5OAQ9oaTmkBLHiqfb+0youdlfAC2+pGHi
 FXnG+l4g8P2eIzB7vqICX7ATzsXPigdLInRyVRYiKDAn1v8GJJB9eUFyc2L4w9+i8AoI
 3hVRzwtEz5eihwNpe9k4QQ4K/oth1FZPrLyBNpUxAUUWAmOdJK2cVe/Kv3uOaChfh4ec MQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qyfbet8n2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Mar 2019 19:05:41 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x28J5XxU032261
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 19:05:34 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x28J5S2i011046;
	Fri, 8 Mar 2019 19:05:28 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 08 Mar 2019 11:05:27 -0800
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>,
        Andrew Morton
 <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190307132015.26970-1-alex@ghiti.fr>
 <20190307132015.26970-5-alex@ghiti.fr>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ee22103c-5060-e39e-7085-87c07d674cd8@oracle.com>
Date: Fri, 8 Mar 2019 11:05:25 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190307132015.26970-5-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/7/19 5:20 AM, Alexandre Ghiti wrote:
> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: David S. Miller <davem@davemloft.net> [sparc]

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

