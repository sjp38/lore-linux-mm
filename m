Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 758D6C04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:10:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 210F02147A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:10:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XdPbt2Cg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 210F02147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFE0F6B0269; Mon, 13 May 2019 12:10:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAF086B026B; Mon, 13 May 2019 12:10:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9D5A6B026C; Mon, 13 May 2019 12:10:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7231B6B0269
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:10:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so9898348pff.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:10:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rP/OPccK5WignsxLuyYpQuz4cQ7lND2uT3MRe0Mdp4I=;
        b=e27lsnRt2EZsPntLOrbclozLdpnilC7QUDk7fbmICb2zP17bL/vXJMFR/zJjhuykar
         uBWQxV/8m2uR0yKS3IVO1jkrmJjApuLVmEQYQ6DZNi4zhk2XqFg2v2ieR/tBnBWehSEV
         77p0UrAqELgsl9uxHzTwcpeaoZPGdridLShd/fYF9Wzq0WamjBbRe5qPwSdqZEE9EMMI
         FYLjzTc9tSG05YdKIKqM+Gbi9RndgSogYWm1h4xdpUUsdBtL/dtKQMd3Al1VC8SrC5kH
         t/Q2bO4R3BEIqo2BkyfJtrohfyDlh1abR5zy/cq92xDjiUAlJUufP32DxN46iLZpiBTf
         PWGg==
X-Gm-Message-State: APjAAAWinN8c0WgX/1N8TJTmf8T073v4t693mGQtum+qT4RLSD4MlvB0
	9d/Jfd9V0+oKxDZFQNaLSQB6QdkU2nhmUXk9YvrS0+1tva3xbpD7J+N+6NsKTBwtYCLM2yMMi18
	AmGfceZV+/JQwYyjvlRpsI/MEOMuwS9LfSqw4tgjZG6KOdAkHnq82UbnOJzl5gqoDGw==
X-Received: by 2002:a65:4544:: with SMTP id x4mr8569997pgr.323.1557763837149;
        Mon, 13 May 2019 09:10:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0+czUTL3qaBhOaVxEw8Ogk1vzkZ6VPMYYdhhiOWwfsMvGFWiTN5hOVOND+6nhraLYxJXH
X-Received: by 2002:a65:4544:: with SMTP id x4mr8569902pgr.323.1557763836365;
        Mon, 13 May 2019 09:10:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557763836; cv=none;
        d=google.com; s=arc-20160816;
        b=jf4CiGF1aS4C7K2pgp91LXNwhVWwY51YWRvA8CgcJHCFlS8AoUq/C7OB/cI4BYEMnZ
         yPBlocSDuizkDi99xUQ4P2VtVg526bKELHXs7IZ/UKxY2EE3tVuhQNPU4JbIy5h6elFF
         W+EMHlNUZ2zaA75DdQh2yYaVcIkgklXk938T0pKpLcRQgT1MNSH06ZdZYw2NroVZXv0Q
         a3VMUaNZoHipaOyK1gQN0cI1mhzS1W+iWroilq0hpnFjaHzjyponv8226YIlqTWcUNJ6
         runXAHqDCeveyUa4Wsd1JhrowWRz7r+mcfG7H2QRxrwQ4e+Hc+3fiSQcEFCp/IQyfbRA
         xGQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=rP/OPccK5WignsxLuyYpQuz4cQ7lND2uT3MRe0Mdp4I=;
        b=bJzuflWZX8+qRgkPiRYN65JLnAU2MQ5rrENtxKi25uhIsrKGTrf0HluH5AFBVMuChE
         jMJTvhWpYIPw7+ZucbOMEuJ0tjesTj6uQ9SKDVz04uhQLZS4/OwP4YtPl4PLxZilKkwb
         y+IVdADWYP7hQ4lrbTs1OaXlBW0UbNUOFxdVkt5Lk6eN4egTIP+7FQKmQLWCOMw7uJLc
         z9nrFF9JaO9bfsXkvYUDORxQJrdQWNVkBLA+PGzKqVu9P9kRHt2wJxpPfcXbXnmcpnkA
         gZ82PCcXHghTn5V1rnAR16SMSqqtberiTm0nkZ0ZGtRH3S7u7FCsnHZannkfmHyv7apZ
         EhiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XdPbt2Cg;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y9si3337952pgj.57.2019.05.13.09.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:10:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XdPbt2Cg;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DG9XTA088123;
	Mon, 13 May 2019 16:10:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=rP/OPccK5WignsxLuyYpQuz4cQ7lND2uT3MRe0Mdp4I=;
 b=XdPbt2CgygTocPQLUHC3NjedbqHDRyQesGdwcmWXviPgtwjzMllFtga5+MbKneALsVs3
 yjrREvz3m+1KhMkbAmmHU5mKjCdcMwtStehqYsXSThUNUdrQ85Pni0YlFiC9dUui5B3a
 z2KCerfTz7tOQNstDjCT+osz5BehIHQznn3pH7jWBkEsFJp3S/58CJK60pzSjlH0WSkX
 xoRqvbd5U6LJ4CA/3k59DS/IZS23ZBNzazWDlXP42YLnSXI8q6dqfkXmCdzE4M5NlrSV
 ZZiGHL6HzfV1ylTaNSzC74wb8ajAmVrXK4gqEHmCqd3iAeJhWTm4xMD3ckI5cRao4+R7 SA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2sdkwdgafm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:10:14 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DG9FRe128443;
	Mon, 13 May 2019 16:10:13 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2sdmeajy04-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:10:13 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4DGAC9w003137;
	Mon, 13 May 2019 16:10:12 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 09:10:12 -0700
Subject: Re: [RFC KVM 05/27] KVM: x86: Add handler to exit kvm isolation
To: Andy Lutomirski <luto@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>,
        X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-6-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrXmHHjfa3tX2fxec_o165NB0qFBAG3q5i4BaKV==t7F2Q@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <40427143-4d13-0583-9182-c38d51d6f9eb@oracle.com>
Date: Mon, 13 May 2019 18:10:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXmHHjfa3tX2fxec_o165NB0qFBAG3q5i4BaKV==t7F2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=965
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130110
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=993 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 5:49 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>> From: Liran Alon <liran.alon@oracle.com>
>>
>> Interrupt handlers will need this handler to switch from
>> the KVM address space back to the kernel address space
>> on their prelog.
> 
> This patch doesn't appear to do anything at all.  What am I missing?
> 

Let me check. It looks like I trimmed the code invoking the handler from
IRQ (to exit isolation when there's an IRQ). Probably a bad merge at some
point. Sorry.

alex.

