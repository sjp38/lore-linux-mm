Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C5FDC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:21:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 276F621019
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:21:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nhBkFt4T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 276F621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B4EE6B0005; Mon, 13 May 2019 12:21:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564D86B0008; Mon, 13 May 2019 12:21:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 453816B0269; Mon, 13 May 2019 12:21:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB736B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:21:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so9934548pfb.0
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:21:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Q1bINLnpf6kvvyhbh9wb20AMsLQSmmPWkmS1SRk8YqI=;
        b=S/a9BL7U2HqTzVjkr2NUO0k/8xpZuZD5JHuugg4915/iD0IRwPqxt9HjxMxO2vYEFA
         tXMLUHwkJu0f9SBdy5LN++y+2qXmBsQc1m75CilOgRh1guEaBQfmrb5wO/79+pJ0Vm0k
         Y+sqblDzoFfs6CdeuhtmlFTK0fvttlnYvyr06kYcIxwqGsmJ0L354Nb9bOwpVWCZfMEM
         mPZfST4daftMpfMD5tNjA9NLvN+iYbkD2qRAOEATRjvNDebdGTlEZTvSZpp/zpdbLjml
         vB+maBfTdwft/lmxSVitywUl9H3jCjKsJDnRWNa70XKWFczulOt4VSZqaZoZblswsR6r
         gKwA==
X-Gm-Message-State: APjAAAXJp3qGE3o9xBP0IWSIvHvAV/Fo0sHmvNAxwXS858bmygR6vlJj
	v2w62xwlB4o9S19P4kht9j4mR2UnTsu3MtWtAwKxpBseIfEgbiBGpXNwwMuc0q6OatsocDBtN3R
	wwyPFOCdk/FLCfcDbh+DtS4MsnJ7tjLh/IMNwjNhuOn1kM5IAytgyocymgO2Frl+gyQ==
X-Received: by 2002:a63:e24:: with SMTP id d36mr32548453pgl.80.1557764502522;
        Mon, 13 May 2019 09:21:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtYnRkwn4nbMsd1d2QttmqcxWJChpWch0c5nUOYSx46I5TjjQrJyZ6u36htOIiE83NVytI
X-Received: by 2002:a63:e24:: with SMTP id d36mr32548370pgl.80.1557764501836;
        Mon, 13 May 2019 09:21:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557764501; cv=none;
        d=google.com; s=arc-20160816;
        b=xBemO70jnhuIKR5/9rt3cnB8juOGYZZkBWc3zKOlpwBCnweMFsBuOEpF5fuvTI3lJW
         3TfXruVFzdFRK60KyRSFMmVDodPa2tYjhZeFsdNyumIiA1d7ifcM2DpTpG2Uy7pS2qci
         +KXrBOguYQFto5di7RaLe/0HYcbogOWodrtzYhu06sqX9pLEE4yoTiRDCvZ3lpHXHdOg
         9v+0uNzMlGGADAD0kq7tAkuwqrl8PhoqCj/4EgHEGVM0gsVT/LjvIJxaql3g1UjjJaWq
         JkK0FuTGWsmnSI4Oo4Doq9nsf3GSlxcqibRrASWBX7f5VlnO/mKHw+DVyOzv8Zif2AHv
         KAGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=Q1bINLnpf6kvvyhbh9wb20AMsLQSmmPWkmS1SRk8YqI=;
        b=pdmUuXZZ7Jk5J6SFXnq/BWZcCbL+bb+/rD0+vVLz/wKYuYG7+GnDtTzKWe2M4w/VuT
         N77O46vNfUvveCkR6hcq90jXYcCd5NQV2eyYS3bGkrp0HEloAXwA0AspKpGjqoHXzATi
         dyfUbVDFuYSjod4e8hJvvKBy3kx3E50O/SXN4kWC/WEHnHzYaiuipvoN4BuSXfEjThe9
         YnKIVC5OOdyqTPZBLDQpaQ1Os7IBiNO1svihkAbEslVgX9GpYYgLPh0HzA93zo13GMuz
         /RHpZnu8qrgAnXHz8Qr8k3/kXr6gzm1KgMY00hgZGFaoc12LZYTrncmrBn+g+he4t2/K
         upCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nhBkFt4T;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k6si16869726plt.204.2019.05.13.09.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:21:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nhBkFt4T;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGJRLm096886;
	Mon, 13 May 2019 16:21:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Q1bINLnpf6kvvyhbh9wb20AMsLQSmmPWkmS1SRk8YqI=;
 b=nhBkFt4TTWkWTnFgnFD71MoII8v8qNZFc6Elm77XUUgHXt3lp0q+2/oYlnroJQfovuZd
 7AUooQFDhTilIYxmjomt35bt4cZVDxxdgwpSMW70sZshbKz6Squu1fXsA1G9vv/f5HX6
 GUWLYDKVlUnNnCTLw0oLk+RAWeJ0kPnHWByjzKFEJScb0qRO7Ka1kYZetAPUcCEbLmkN
 2Yivm6DE52Kq/b8YnYYbi/ZdNnrK91hgGkL8L2tlU/iQSMUGLSJ/Oq7IbFs13qTP9Ib+
 H4dJvl0TnaXAPNrSsalPig97N1VCTTjKUF1rhuJRUxu3tNWO0Zp/0wnmeLwyR8zo5VcO Iw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2sdkwdgcje-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:21:23 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGJZnA118286;
	Mon, 13 May 2019 16:21:22 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2sdnqj2eqk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:21:22 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4DGLLLW011879;
	Mon, 13 May 2019 16:21:21 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 16:21:20 +0000
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
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
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrXADiujgE6HJ95P_da5OyB05Z5CqR028da50aCUHv4Agg@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <0ed10cf2-d21f-3247-5b38-4cc1f78e38e1@oracle.com>
Date: Mon, 13 May 2019 18:21:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXADiujgE6HJ95P_da5OyB05Z5CqR028da50aCUHv4Agg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=984
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130111
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 6:02 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>> The KVM page fault handler handles page fault occurring while using
>> the KVM address space by switching to the kernel address space and
>> retrying the access (except if the fault occurs while switching
>> to the kernel address space). Processing of page faults occurring
>> while using the kernel address space is unchanged.
>>
>> Page fault log is cleared when creating a vm so that page fault
>> information doesn't persist when qemu is stopped and restarted.
> 
> Are you saying that a page fault will just exit isolation?  This
> completely defeats most of the security, right?  Sure, it still helps
> with side channels, but not with actual software bugs.
> 

Yes, page fault exit isolation so that the faulty instruction can be retried
with the full kernel address space. When exiting isolation, we also want to
kick the sibling hyperthread and pinned it so that it can't steal secret while
we use the kernel address page, but that's not implemented in this serie
(see TODO comment in kvm_isolation_exit() in patch 25 "kvm/isolation:
implement actual KVM isolation enter/exit").

alex.

