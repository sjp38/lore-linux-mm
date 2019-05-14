Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB294C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5161D20675
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:34:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qQ5fpl3R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5161D20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043B06B026B; Tue, 14 May 2019 04:34:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01DAE6B026C; Tue, 14 May 2019 04:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4BE26B026D; Tue, 14 May 2019 04:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC8466B026B
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:34:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f1so11525417pfb.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 01:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Jt8E3lVLhJgEFEn3MWp6fWcs0kIahKV5qTQyv9mVy4Q=;
        b=gs4Ce8x1EKC/oAmR2EGcbVNCPpHXInjsA6uiV/XCGaJxeavjtqAnmTEz1m5QSQh+1j
         WzQQ//iFlkbjqBdhsFrqiyJiiqUAGygcVYuVQcDJhZBZrjFkTP4SsoIUCPcsdWsvfIPX
         +1qHRgnsroyTiqY2fbt1bYqWFRVw6sZ/4sll/nynPTinjXjDVSLi2FaDRWr1jpGkH5ag
         wmjqMFqfAw+WGd0OSBrWEEOcXW6ETL7YEC6bTI4w5iL8LnGA/DydriSLGUsOLmG+gzIe
         PQrho+FSGpnD8qmIDQLTFvs5K5af0y+KeVmmJb0LNYUQ3F6YgWzhOeqFVvKJM3xTWoEX
         mBrQ==
X-Gm-Message-State: APjAAAXA/sZf14jB5noZBYNdOF7VLqiF8kNGYTEMWGJu7iysc5yLEnRX
	qSlb4rovDqQ1bnWuHpEtQjp3EpCka12TMDnxnksRrAPs2wEUYPneGxHOe0CGvqd05BIMfcNg7sn
	ZC7wLCT0vYZAWErhAD+eFCjdKvrY8vy3azuta6bCCftG+GCGO/ZEn16fG0U2WCuLo+w==
X-Received: by 2002:a17:902:9a03:: with SMTP id v3mr37647281plp.27.1557822856254;
        Tue, 14 May 2019 01:34:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw34u0rT7/0IEs1ajMqxBvCoMaA2yT4IdridthNP6GPevePT6N+u/otuzduTnck+tY30Fjr
X-Received: by 2002:a17:902:9a03:: with SMTP id v3mr37647219plp.27.1557822855458;
        Tue, 14 May 2019 01:34:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557822855; cv=none;
        d=google.com; s=arc-20160816;
        b=QlK2AdqfjkHXrwX3Ui8HH2M601NXWcY62kA+cHQeaqniLLMM19/6cNQd56+HUAmpUO
         8tBfoA++6ogAi4nH3g70wptQQPcZHe+zD5RkLJd3atJlY8WFxhpI8vKILuG25YEiCR7Y
         Ihc1gc07KjrggWoSz5gFjpYr9uK8r8xhTpFJLgxQNxXtHuQUyoeRdXJEtSXjKairIbeP
         KPxP563PhrC7OF03lLkaLGcUhUbbeTxeIifWTz6NZ3/V0195CNsh8RxtAVZ0iZs8hKFk
         lhGlkVN8oFYJA205zE4kiRq6itX1lyOsmKeHHNk63OzfCerjiAT9iiiFI31bg+pmU8uz
         PJTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=Jt8E3lVLhJgEFEn3MWp6fWcs0kIahKV5qTQyv9mVy4Q=;
        b=aGvSK8ngMD8UTUHuD7TKoq6t+SOg6FwNNL0wfT6B1YsF1Etx+qvHkYeoBj+aYNRapW
         HinrAvlRa9YhxfUNNVwrrvfa1TCDSPwVMMHLNpP8rsCzjZtwm7HYt5do51xJl3xPX5UQ
         xlww9uO0pHb0V6kvCzeCJ0JYPTXdheEjd3ZbHe/eHOvOZhvT6LppAsY4IZTDkp0PTDoM
         efnihybncRnZ+SYKdf7m1+IsoillQQpz2WjN03aGzGJrdg3464p9oE7f13+l0mBFkquE
         lf5EDHQgplLXPUIp3T4IPKE1lIM4X4drNWzzIgsxzwq20tENKQ7nTZtz2T9IvMASu0dY
         tSbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qQ5fpl3R;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l61si8159382plb.288.2019.05.14.01.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 01:34:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qQ5fpl3R;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E8TLGp056543;
	Tue, 14 May 2019 08:33:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Jt8E3lVLhJgEFEn3MWp6fWcs0kIahKV5qTQyv9mVy4Q=;
 b=qQ5fpl3RpL05hBrLUsIf1E+1aBvQCu2pudkdg7nNbgXKbiyQrs3rzMBl8DOqaVQHvlUo
 BEMxNYvh+HArNT8mJVSIONSMqsMK9XNYSZrJ6jhaDP2gpLbRtN/8Cfq3QYYSD/2QoUpN
 gY/xNBPRsOfaJO3Spebcq+HSYbB6hOT3UVOwvAYwWeOvBicWFXqngxnNbX9nmkLuRRBr
 kqTold+bwX7DdG8BDGFVbeoMJtAu5Szv1J4ICH0xH/ml/1B5RJ6ycOs5ilOrzToeBSDh
 opo8MwXBSHn7tq/EQfmSrfdI9mcEB23G40rmbZl4jGKA2UK2QMjkaCDlNwVn6Aphx8OT Lw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2sdq1qc40q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:33:58 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E8Xaii012801;
	Tue, 14 May 2019 08:33:58 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2sdnqje85m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:33:58 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4E8XtZr025473;
	Tue, 14 May 2019 08:33:56 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 08:33:55 +0000
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
To: Liran Alon <liran.alon@oracle.com>, Andy Lutomirski <luto@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>,
        X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <d366fb99-16bc-30ef-71bd-ecd7d77c6c7c@oracle.com>
Date: Tue, 14 May 2019 10:33:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140063
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/13/19 11:08 PM, Liran Alon wrote:
> 
> 
>> On 13 May 2019, at 21:17, Andy Lutomirski <luto@kernel.org> wrote:
>>
>>> I expect that the KVM address space can eventually be expanded to include
>>> the ioctl syscall entries. By doing so, and also adding the KVM page table
>>> to the process userland page table (which should be safe to do because the
>>> KVM address space doesn't have any secret), we could potentially handle the
>>> KVM ioctl without having to switch to the kernel pagetable (thus effectively
>>> eliminating KPTI for KVM). Then the only overhead would be if a VM-Exit has
>>> to be handled using the full kernel address space.
>>>
>>
>> In the hopefully common case where a VM exits and then gets re-entered
>> without needing to load full page tables, what code actually runs?
>> I'm trying to understand when the optimization of not switching is
>> actually useful.
>>
>> Allowing ioctl() without switching to kernel tables sounds...
>> extremely complicated.  It also makes the dubious assumption that user
>> memory contains no secrets.
> 
> Let me attempt to clarify what we were thinking when creating this patch series:
> 
> 1) It is never safe to execute one hyperthread inside guest while it’s sibling hyperthread runs in a virtual address space which contains secrets of host or other guests.
> This is because we assume that using some speculative gadget (such as half-Spectrev2 gadget), it will be possible to populate *some* CPU core resource which could then be *somehow* leaked by the hyperthread running inside guest. In case of L1TF, this would be data populated to the L1D cache.
> 
> 2) Because of (1), every time a hyperthread runs inside host kernel, we must make sure it’s sibling is not running inside guest. i.e. We must kick the sibling hyperthread outside of guest using IPI.
> 
> 3) From (2), we should have theoretically deduced that for every #VMExit, there is a need to kick the sibling hyperthread also outside of guest until the #VMExit is completed. Such a patch series was implemented at some point but it had (obviously) significant performance hit.
> 
> 4) The main goal of this patch series is to preserve (2), but to avoid the overhead specified in (3).
> 
> The way this patch series achieves (4) is by observing that during the run of a VM, most #VMExits can be handled rather quickly and locally inside KVM and doesn’t need to reference any data that is not relevant to this VM or KVM code. Therefore, if we will run these #VMExits in an isolated virtual address space (i.e. KVM isolated address space), there is no need to kick the sibling hyperthread from guest while these #VMExits handlers run.
> The hope is that the very vast majority of #VMExit handlers will be able to completely run without requiring to switch to full address space. Therefore, avoiding the performance hit of (2).
> However, for the very few #VMExits that does require to run in full kernel address space, we must first kick the sibling hyperthread outside of guest and only then switch to full kernel address space and only once all hyperthreads return to KVM address space, then allow then to enter into guest.
> 
>  From this reason, I think the above paragraph (that was added to my original cover letter) is incorrect.

Yes, I am wrong. The KVM page table can't be added to the process userland page
table because this can leak secrets from userland. I was only thinking about
performances to reduce the number of context switches. So just forget that
paragraph :-)

alex.


> I believe that we should by design treat all exits to userspace VMM (e.g. QEMU) as slow-path that should not be optimised and therefore ok to switch address space (and therefore also kick sibling hyperthread). Similarly, all IOCTLs handlers are also slow-path and therefore it should be ok for them to also not run in KVM isolated address space.
> 
> -Liran
> 

