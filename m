Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F6B6C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB2F2086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:37:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5XJ/WDUH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB2F2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 545C26B0005; Tue, 14 May 2019 11:37:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F61C6B0006; Tue, 14 May 2019 11:37:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BD466B0007; Tue, 14 May 2019 11:37:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3FF6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 11:37:23 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id z66so2789175itc.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 08:37:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K6RAKYDjcjRrn7OwP84UHYgsO7ChGZaEr+sqPb3xwhc=;
        b=MAkVVXK9j6qH5qgNsjljdbuzHYAlMjumZi1bBSM2Aak6ATzMNUXRC2Nm9RGN4EKSFi
         aNrKUMSgrO7Vk3mj6Vip8soOALLf5rOjXPuOsdRvxHo8CWBvmP9PoJf0q3aql48Xx7GM
         V3Wl4opT0Yj2We7XVUfjjcPyeOYcN+zbxHHPmr4rvxTdgrAS+OQN+MmTvzN+Lt2cQN5z
         tQ/Gfv8+33DbvWhRoYtpB4I5/MNb8EDBbndcL5PChw6n0ci1BqJDiMWJbSEdXei6icN2
         19InIOmDz4FEgMJkV62AkvfoS+0dEoincexnCSZoc6c4S68T+HyftynLwF1Wx8h93qhE
         mYig==
X-Gm-Message-State: APjAAAVcuuSNJNk/kTWMYremN2sFPdDqLGgC/vY3t0tREUI0YhMHtsUj
	Vvkx2Zf8JwTH1MDRjsnLPSdZ16ZA9wf74i6SX2uR1qln2xpDar+74aRbvjEXNBcCUpHa3yWLBkZ
	qVcvouJZiEn+Ebr6wNQ76UBO8MSKorWZilBeGAdteWqlK8ICMjo/C88yFIh7xtzzG1g==
X-Received: by 2002:a24:4cd2:: with SMTP id a201mr3769846itb.26.1557848242807;
        Tue, 14 May 2019 08:37:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqv0XRwYhwAaou4nnyrcObV9Tq0cJWs6l3nSMitIlh/dXSvp6GZTdaNcXrgci6al3WSqdF
X-Received: by 2002:a24:4cd2:: with SMTP id a201mr3769797itb.26.1557848242151;
        Tue, 14 May 2019 08:37:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557848242; cv=none;
        d=google.com; s=arc-20160816;
        b=HRe6LOo0UxXIhT90yvv3Oiy8lbbwWcS2Ma07usU55Gkn784xTnEZy1I+Eimh9JpQKN
         0a2da4bNHiFT2hpgeEG3z+3mtkmGuyvbXzH+JASt+RRmDmzIuT8kstyBbJyUwT//BPAD
         IccuJ8n6N05J7VR97TRYWW3QqgsMgRRRqfnCJroQNX6RTxg26/qK///NzU6VmHhawwbt
         39r2zALdrliCyBfhteMfyNWwULIna5wzsz6kehBTPFAXD+0IkkqEVhFnMsm/Kv+087AT
         DIrPvgv1cjA9vcYGEIpQosJl9jJgBLdYMX22miSYtr0rz/nlgCYGwJMX6sviiGsYg318
         gTIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=K6RAKYDjcjRrn7OwP84UHYgsO7ChGZaEr+sqPb3xwhc=;
        b=CmPEHzZJpdPf7KfBpVMx7dXOFc11I4R+CGpeRZ1mRfoRW4mrrIVZPL9eYjuQsSNogO
         GA5biyV/hVthe6I6vV76FB68sjKnbPJ1uB0nXu+ztyg4qOMyE+silmnJwAlb9DrCM9ZL
         sXRwGzNxMq3LD8/VF+3d8c+fydeS9D1w2PLtDqM36OpPSP29zDoaJ/0YR37+1lfg7Jow
         jyVU/xbCFcPD3+WaeRa/FFuo3VD5bydu1/9pM0LYb8EU0NnPZiSua2nljupQ3YJr2Viy
         ZztPXYsc2zBtFITd9/DqXOhiSbMezqIlxUYmMhUWXL+9aOwfYzkQ+Cpdl0cGHzBe738Z
         jWtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="5XJ/WDUH";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c1si8980507iot.116.2019.05.14.08.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 08:37:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="5XJ/WDUH";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EFY5Ad041917;
	Tue, 14 May 2019 15:36:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=K6RAKYDjcjRrn7OwP84UHYgsO7ChGZaEr+sqPb3xwhc=;
 b=5XJ/WDUHZ0rtX1wy7iGiSQInjd4Yje8V0Nmw7F2TpN62bao4hby9ViD40alDqoIimCcT
 IqmNrySa/hvm/yvNnPV7kAphqhwRpXXmIo9tmtGOcJefID4qORAU6rmiyGDpSb8VzGkL
 wb2TZXj3OraOSmMlRjSCXoGgbjRn5+uqIUwZ+EjtnghualrShvTzaqilDUUKkav3ZVEG
 DUvMwQXC/emAR1qaIFGPMioz6EbIWV+l5UJVwALQDf2XpMOl/tGCRp2uLVjWvH3o5D1j
 ygyljCSo8K2hmvy8qbg334BYRGKGGy7EcRlTxjFeqnVaX0FP4NSfdl91Nuo1L4e/hW2f uQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdnttpxv1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 15:36:59 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EFZLrw135409;
	Tue, 14 May 2019 15:36:59 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2se0tw7m68-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 15:36:58 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4EFatFM011608;
	Tue, 14 May 2019 15:36:56 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 08:36:54 -0700
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>
Cc: Liran Alon <liran.alon@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>,
        Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
 <20190513151500.GY2589@hirez.programming.kicks-ass.net>
 <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com>
 <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com>
 <20190514072110.GF2589@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <95f462d4-37d3-f863-b7c6-2bcbb92251ec@oracle.com>
Date: Tue, 14 May 2019 17:36:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190514072110.GF2589@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=941
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140109
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=973 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 9:21 AM, Peter Zijlstra wrote:
> On Mon, May 13, 2019 at 07:02:30PM -0700, Andy Lutomirski wrote:
> 
>> This sounds like a great use case for static_call().  PeterZ, do you
>> suppose we could wire up static_call() with the module infrastructure
>> to make it easy to do "static_call to such-and-such GPL module symbol
>> if that symbol is in a loaded module, else nop"?
> 
> You're basically asking it to do dynamic linking. And I suppose that is
> technically possible.
> 
> However, I'm really starting to think kvm (or at least these parts of it
> that want to play these games) had better not be a module anymore.
> 

Maybe we can use an atomic notifier (e.g. page_fault_notifier)?

alex.

