Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D185C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:56:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0D9E2084F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:56:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LlxuNk4L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0D9E2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774F16B0280; Mon, 13 May 2019 11:56:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE7C6B0281; Mon, 13 May 2019 11:56:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550056B0282; Mon, 13 May 2019 11:56:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 176826B0280
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:56:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i123so9854727pfb.19
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:56:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IDGztZNSk3EOeDwS/6bGjcJdmBuu3X/lohbpa7Ehouo=;
        b=ekbzXxsehH176y46PCsAEKHjIoy31xYduHm4A3BhRbUVZiXcjyXwEk+xQCdfkz5Yf3
         VZPbU7s3+px9wK9GtsWFkUgSIKZedxSu9kbKZR6765tgxKvXB0PHaBNDOoxzqnAQ36E6
         HpGLdZWz+aECmFI7h4g6tq3gtDzzXRemXvQhizBRDIH5Yi0cA69vz7bjpY1A37hC/HTI
         +yh7djkARt6JgTL9QBvkgvyhzDi3tlbTy9VQBQGR1DQEJjkW2z/ByFp/DqDowcQnXCt3
         VOy/UY9FSfQwuF5V5Usb97hnEiFGRFX9Yfy5IZtgX9LeaccBUEc9xsLBIC963GrYrhYd
         8jIQ==
X-Gm-Message-State: APjAAAV2ZXhcxe1uob15QUY72+4l1egCIX96N72kr2ign4jFENM5hlqC
	JTT2gkqw8xzE3YhKRWIBK9onbYNWcVlAQKdMk2+2VQw1tBhqGrKnoXLmX0v1/wyHbsB/IBtuLIx
	pko7cXz9yxqMRqZ6cLNtNCYwSTMvuu/7O0BO8qcS+kjdGG4ao1fOhVO0BsRPVVQM9KQ==
X-Received: by 2002:a63:b507:: with SMTP id y7mr32153209pge.237.1557762976767;
        Mon, 13 May 2019 08:56:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJ+7WXGGENYnh9r5U7wCHvFP4w82hOnE4hNrvMTeHRLc2gpLHJBZyCufwm5NaLcEhcYQ9a
X-Received: by 2002:a63:b507:: with SMTP id y7mr32153132pge.237.1557762976108;
        Mon, 13 May 2019 08:56:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762976; cv=none;
        d=google.com; s=arc-20160816;
        b=nint3Jw8Re1BMW60mu303RWVPJI7dQ8CNpgNiYWRTsk9E4QYy5YG3mhumOo0SiXkM2
         +sqqNlH6t5K1cNI7GOgGHIBhD13SzE+fh3gpP5DlJ+Pl28db8zUJYrsrEfClS4kiaLwv
         VsyuKoGTTuEq68Aid+p/W0XuuLG1MzKahbw82YU7ILRtqQkB0iWUHM8vqv/4igso052C
         5ln4bJMxYyW/duhupG3chvGiF0N3cDZvmVh8/g7Ofg28y8VuONEiMnpWLpZl4IZsltdm
         CanW1TIHtkHLMsd8LUn1jnvKW6nMMv7kmIutToUE9E84D6QqI6rJBfwSnRGt0Z3XvhSn
         R9Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=IDGztZNSk3EOeDwS/6bGjcJdmBuu3X/lohbpa7Ehouo=;
        b=CFbbj6E/aSrmhJog53jCKfqE65KA9B71GKGq8Xaa26fW+1dzdzUzlxA3tqKpbateqR
         ey1LWg5vN/zzGrKJ0eXMpTR91WRhlzuhxSdPsuVNln/FqdcmoNiUj+mLdQBZKpwUGjxc
         lycU0U7DrXzLvjVkhxomyhMsnuqNQclGYPXND++47pwN56P+Jsl3juTexLE4Sw1ALxC2
         nFzegSGz0SupSSuB28z7NxxdQZYgFo+/mn9tQBKD7ndPfTj8ADfngY+yikoDU3Xt7kk+
         5lGqQ5v/rTO3IsNFjVHSj9TqbLnqeSRiXyVLK/mjb7DB46khbBdfbAkio1uRxPoljEDY
         T/yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LlxuNk4L;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b14si8617pgk.423.2019.05.13.08.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:56:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LlxuNk4L;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DFs1hJ072718;
	Mon, 13 May 2019 15:55:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=IDGztZNSk3EOeDwS/6bGjcJdmBuu3X/lohbpa7Ehouo=;
 b=LlxuNk4Ll9o+8qngaWj0VqzCQgTsSXzex1axGc7UkNh6H5gn9YstC9amPWxaaDjGAGxy
 Sxa/tWIucIiMuDc5eNs8xpePwQDo9RjRHZDlx4gteU7+7qD3qJfcGlJ8jfI4p0KU2bXF
 hTrOvWE9u4F+yBZzqkpFK8w/hbkYVOGGj1HI167yYV1YLAZhrm+AGaMuoc32h1acCEu+
 Sl+LCkuMuGLucQ66wPTJ9InxMzlRKZsSsAsH/9IxUOkunfxL+CHBTWsawzGKlt1dVVMx
 tOIPcxxVfu7ZL49L746BHIKd3GBFDSYj5TXX0IQIUKLyuedXoNGVX6/hX8WvrZ3cNXni Fw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2sdkwdg710-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 15:55:54 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DFtFss087063;
	Mon, 13 May 2019 15:55:53 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2sdmeajnva-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 15:55:53 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4DFtmTB016531;
	Mon, 13 May 2019 15:55:49 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 08:55:48 -0700
Subject: Re: [RFC KVM 02/27] KVM: x86: Introduce address_space_isolation
 module parameter
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
 <1557758315-12667-3-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrUjLRgKH3XbZ+=pLCzPiFOV7DAvAYUvNLA7SMNkaNLEqQ@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <1c541cde-a502-032a-244b-96e110507224@oracle.com>
Date: Mon, 13 May 2019 17:55:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrUjLRgKH3XbZ+=pLCzPiFOV7DAvAYUvNLA7SMNkaNLEqQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130109
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 5:46 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>> From: Liran Alon <liran.alon@oracle.com>
>>
>> Add the address_space_isolation parameter to the kvm module.
>>
>> When set to true, KVM #VMExit handlers run in isolated address space
>> which maps only KVM required code and per-VM information instead of
>> entire kernel address space.
> 
> Does the *entry* also get isolated?  If not, it seems less useful for
> side-channel mitigation.
> 

Yes, context is switched before VM entry. We switch back to kernel address
space if VM-exit handler needs it or when exiting the KVM_RUN ioctl.

alex.

