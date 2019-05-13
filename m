Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46031C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC163208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:28:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JM/MYBdm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC163208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81FDF6B0005; Mon, 13 May 2019 12:28:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D09B6B0008; Mon, 13 May 2019 12:28:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BF006B0269; Mon, 13 May 2019 12:28:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8BE6B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:28:23 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id u131so6581itc.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:28:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FYrhA7egepTfvRq1AFeM0qLEx0DR5PBRWMLgWVnJWsQ=;
        b=A+41z83p0BdnkQW0wZBLCpye4/0EpTSfz/DC5veqKuIsV6jWAssdPS850Y79S6quHp
         IxMRy6ejuja93Cj13afItvLLDqMyzpnB2aLDqeYrY43cmo6UDeGbyosozu84JLk6VhFW
         5+/ly1D6BeJOXZYU/agP4dtp0/QTCMrYUW4KzjWEBjEAGgHEVImBmmqOqf/NjGeAgydc
         HnBLQ7PO4BL3HpjjOy2uDGQsSOM46iiOX1q1vmYcEhCxZVcl6mMHpMV6E94pzCwkTpjy
         HW+BXsD0qUENFnAOhG61SLpLEYZSdE16AMbs/ckCUGn+9k7W1+rIRFr0BG+nIwlcj5q2
         K2Mw==
X-Gm-Message-State: APjAAAVjH8fWDD81cS0pk1J7KssHDDvfzZH8VVvXpHdoRrZRCMWt6cws
	I0d/WnJaDep1cYen6BoHEUIQhJ6ZnUBuGgHPVM18eYRsS4djozIHXh8P3Ctt8X7rob70jyK8TFo
	PA0HkpWiSFV93HiG7/oFJbKTjrJKv3q9pHl7DyR1vTYaFHMy+njQ7K4RUehapKwBkMw==
X-Received: by 2002:a05:660c:20e:: with SMTP id y14mr17433128itj.17.1557764903049;
        Mon, 13 May 2019 09:28:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLdc+r6u/ou0h43JguZzkcN7bDPGMH73us24ZtqhGdC+UTaPzfnR31T9Auul9537CFkbxr
X-Received: by 2002:a05:660c:20e:: with SMTP id y14mr17433100itj.17.1557764902468;
        Mon, 13 May 2019 09:28:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557764902; cv=none;
        d=google.com; s=arc-20160816;
        b=IL1ej6ss5KjoJ6veAB1EbGkvGqYO2wJYOrgfWC8hFPcdVSRxxVwceGNvmqKTEoD+To
         Qlfaa1AEKKuktUi8mvonU3Spa9ILQeLipxfNBpIil3Fql8bHUfzQVCkV9d5t1l0l4I9m
         Zz3ZARnXB6QmJjAjIZQeLryVXB36cj6ZDXc0ntnTEfCywoQgTP+O25EBG6pzHKza/dXx
         +t0dvQHz9DxzXUcQgc6rpSSwsQhHGQfDDQ2i7VaJJA97/DdbWyaUWxxfJ4GZaTdDPR5o
         3pwPKzgGWacNbS5LjbEFIO7jnYLZoRB7ejw/CCBW6DAidOIQSUpaO9WBk/l0zqdHze8h
         7cyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=FYrhA7egepTfvRq1AFeM0qLEx0DR5PBRWMLgWVnJWsQ=;
        b=LZAwSupdLdwRFmckEgzeGva0vkbps1gyOnOIhAghqn5lhm09g7prUUYkeztPYaGPms
         EfiYPzkH5ZJ7/poPFUXiZIrsTjWOMS1ockt1JV4Ukmvv3Kupf8Dy6QDd7Gb6ztfXL2ut
         UIM4ZehFtzx3/KHkGYymOhLhd4FCL65gqBSVgVRj0B5Vl7idzgogLJhR63GMQdmasr4Q
         unzM/pKSVM3/bK4YuIgZQGp9WfmWQbruaOMYdXuMm+EX5HrmDntpCkW9a9d/u/FNiOmf
         kSZhmpobx07NhaDkRhZrZWk15zpC0jJH13wJC5wToR/9QUwq2HxuASMxV2TJCAqy1YYf
         bcKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JM/MYBdm";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 67si7746255jai.65.2019.05.13.09.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:28:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JM/MYBdm";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGNxNv088885;
	Mon, 13 May 2019 16:28:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=FYrhA7egepTfvRq1AFeM0qLEx0DR5PBRWMLgWVnJWsQ=;
 b=JM/MYBdmNI6fFjLoGthcwpEXl9/Q6FhIqpsnCQ/BkenPG8S3EemOIYf0qHZKwH9r6swU
 3W08FCV/MBFSOmti4xQvPOp8Bf8IjFwM6Ft4Xk8wc45eTYIomnnH/xdarjyLowUZdlZ7
 0/jl1dVkSjbyok9Tn2nHlEu9gPiwnIxz7UJpBmh2MTDeF2Y7iO/lnwZ6kEhg+MA0egip
 HTkDQcfvDyFLE/STY78ukF9EWR9b5KDeLgSclCp2uP2RlVycLwSomEtzHCzJSlwK+A5K
 d6tT5kdeTExB5VdxFJdybuBxZc7pR8Ykx/LQ6U9q8h6+NrNWEGkyxNtbJmOJkmMrtlT3 0g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdnttg880-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:28:12 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGRXaG010806;
	Mon, 13 May 2019 16:28:11 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2se0tvngry-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 16:28:11 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4DGS8t7007669;
	Mon, 13 May 2019 16:28:09 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 09:28:08 -0700
Subject: Re: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
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
 <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <64c49aa6-e7f2-4400-9254-d280585b4067@oracle.com>
Date: Mon, 13 May 2019 18:28:05 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=923
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130112
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=954 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130112
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 5:51 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
>>
>> From: Liran Alon <liran.alon@oracle.com>
>>
>> Next commits will change most of KVM #VMExit handlers to run
>> in KVM isolated address space. Any interrupt handler raised
>> during execution in KVM address space needs to switch back
>> to host address space.
>>
>> This patch makes sure that IRQ handlers will run in full
>> host address space instead of KVM isolated address space.
> 
> IMO this needs to be somewhere a lot more central.  What about NMI and
> MCE?  Or async page faults?  Or any other entry?
> 

Actually, I am not sure this is effectively useful because the IRQ
handler is probably faulting before it tries to exit isolation, so
the isolation exit will be done by the kvm page fault handler. I need
to check that.

alex.

