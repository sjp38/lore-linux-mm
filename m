Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13646C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE5FA208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:00:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bIbPRVQM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE5FA208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B1D6B0005; Mon, 13 May 2019 13:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EB2C6B0008; Mon, 13 May 2019 13:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0653E6B0010; Mon, 13 May 2019 13:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C20056B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 13:00:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f8so9581716pgp.9
        for <linux-mm@kvack.org>; Mon, 13 May 2019 10:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4xiDPOzSHcQpk0xHvpIXFduYKLuE1ShLeQljNETPlH8=;
        b=LeMl1HFeguPqTwqwQW8OYAx2AWH7pNWMRdagRtvF3GDlMQ3K6x3mZx+GhhL0krI50Y
         i7/9lBH1qCxhoTrRDg8tg3lWG77OeFShh6gdbLLIvBKlX1dUQisgqswOkeq/UE+HNA3K
         Zia3uj6zminsecL3Z2ZH6RL5afYOw53W86KK97QT9Pt2hFioegbY9/nRqvO3KtZPXd6p
         J4DNuFVEAYZxx6XIf0bhL/QllBkkAunFabp4IQJMUOl1sWbfPp+7iO7clGTCoEYFIwig
         qNN5J4ICzVZhIpY71zUGzswUBNzc0otJ7Kl5tmagGpZkI9E8FfZZY/ZfI/+WiseVh9yo
         huYQ==
X-Gm-Message-State: APjAAAUbUzsSkOCTfxQHGMAXocifyE1+C5KeaoIJzklLTydY0hA4QwLM
	/1ATecZgTUBy3SCQxXzhh4Lo0sJxJA/DYsy0/V8RTejhheZSwQ565uFykSd08QqDmLpNcM0WrX9
	1zoCoBcw47xcvlCMY47CRqI0dtCQZB4qjk6kjXHKWAN9jg0jW50XcH1mFfGZs5nO3cQ==
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr10012454pls.146.1557766856247;
        Mon, 13 May 2019 10:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqjrrjB6K0Pkh4+roSX0ssRobNesHAkBo4apbgfflA+i18/nBCJOBdpQPghziBMO8errKb
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr10012316pls.146.1557766855267;
        Mon, 13 May 2019 10:00:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557766855; cv=none;
        d=google.com; s=arc-20160816;
        b=lVdhPJBCZSDzXtc/BK6YVgijlrADavvS1sO7j6/ljBVKMpooN9fSeagu6GWOhM4rAs
         lK30/MYnz0h7/3OVYvjGMRiuKeOB9ZTDrVBSHkgGsFoSXo13cFTiXOE3Z22pv1LMnAIg
         AulfXGAbvW7F00J51VzfsI0nVMc+0V2obVKuVaLGxx1dQZd6su/bhcpIlfEK9klDiEfu
         zWQC19rpxzrWTosFVd0MDOPou7e08Jc+lxtHwcRmxm/uPuh3chExAuZ0G2eqZIEMek1e
         NtLHknl1nRJ7szanpUU//A9RYbVLmEkeQYbh+EE34Ci/2vfWJ5wsN0XIAQgmxlxjannQ
         /HDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=4xiDPOzSHcQpk0xHvpIXFduYKLuE1ShLeQljNETPlH8=;
        b=c5iBd+sYYkorLxVZTJT8mwpeMmc1Gr8TvcdKRji9oVxxfkbp+VL+6/SXw4lIg3GuNQ
         AIoZ9qnzgkkWQh+Si2U0gQ/dSU1KC5CAupmDziDWDoloKc+hWfOC3upnYoBS8atZ1/Bc
         LNi2AznYF6sqtKI7HONAhOEt5apSuG1ezDyi9Nf6WU1wg46q14XkttUUUJe3TGao9xuR
         ri+gFKFtD8TAlHjfN3LZGpqXO4Z/b6buW+jvTdOx0nJjQY4I2dDgx28SxKiPPyUo8JmM
         7DKTBWDsSXrA+ds4687urZUNye51tJKgrcgbnrz/qGFhAI4ZsQ7YMoN6OBSK4Dua3D2+
         yuHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bIbPRVQM;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id cd7si8628338plb.377.2019.05.13.10.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 10:00:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bIbPRVQM;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGwgch132176;
	Mon, 13 May 2019 17:00:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=4xiDPOzSHcQpk0xHvpIXFduYKLuE1ShLeQljNETPlH8=;
 b=bIbPRVQMgiUHCVQwzQuqCiiZIMI38WFqpvE61wvkwdHcTyhzPfLq4oD3+D8wgtXVJoxY
 8pC1Vh0vbaJ30yemQlGtGrVuLAlyjkghNmAbqrM8fv46zQ94FvB757novPa3rKLV2imw
 0Rsln4Ilxb01BbtFroGEkx5twV4K/0dcJwz27KIIJVo9abCRYhOxxhQrvBsDBZRIO9Ty
 fRd5tFBbwgLIO5OYE3zC4KfSunv09l19QUIWVVDyhKWbZBQOOX4YplDNz7gkK6j5i6n7
 j89WdQO6nRc6bsocVSBH3ck1exCVyYHV40l8U51e46C4tjj5CNcjBeBCdDLOJw5BdN4S vA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2sdkwdgm9w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 17:00:37 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DGxHjO090835;
	Mon, 13 May 2019 17:00:36 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2se0tvp1hb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 17:00:36 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4DH0ZfW031069;
	Mon, 13 May 2019 17:00:35 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 10:00:35 -0700
Subject: Re: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table with
 core mappings
To: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>
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
 <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
 <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
 <CALCETrXYW-CfixanL3Wk5v_5Ex7WMe+7POV0VfBVHujfb6cvtQ@mail.gmail.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <ec26a85f-ff1c-89d9-5e6c-ff42e834c48d@oracle.com>
Date: Mon, 13 May 2019 19:00:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXYW-CfixanL3Wk5v_5Ex7WMe+7POV0VfBVHujfb6cvtQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130116
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 6:00 PM, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 8:50 AM Dave Hansen <dave.hansen@intel.com> wrote:
>>
>>> +     /*
>>> +      * Copy the mapping for all the kernel text. We copy at the PMD
>>> +      * level since the PUD is shared with the module mapping space.
>>> +      */
>>> +     rv = kvm_copy_mapping((void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE,
>>> +          PGT_LEVEL_PMD);
>>> +     if (rv)
>>> +             goto out_uninit_page_table;
>>
>> Could you double-check this?  We (I) have had some repeated confusion
>> with the PTI code and kernel text vs. kernel data vs. __init.
>> KERNEL_IMAGE_SIZE looks to be 512MB which is quite a bit bigger than
>> kernel text.
>>
>>> +     /*
>>> +      * Copy the mapping for cpu_entry_area and %esp fixup stacks
>>> +      * (this is based on the PTI userland address space, but probably
>>> +      * not needed because the KVM address space is not directly
>>> +      * enterered from userspace). They can both be copied at the P4D
>>> +      * level since they each have a dedicated P4D entry.
>>> +      */
>>> +     rv = kvm_copy_mapping((void *)CPU_ENTRY_AREA_PER_CPU, P4D_SIZE,
>>> +          PGT_LEVEL_P4D);
>>> +     if (rv)
>>> +             goto out_uninit_page_table;
>>
>> cpu_entry_area is used for more than just entry from userspace.  The gdt
>> mapping, for instance, is needed everywhere.  You might want to go look
>> at 'struct cpu_entry_area' in some more detail.
>>
>>> +#ifdef CONFIG_X86_ESPFIX64
>>> +     rv = kvm_copy_mapping((void *)ESPFIX_BASE_ADDR, P4D_SIZE,
>>> +          PGT_LEVEL_P4D);
>>> +     if (rv)
>>> +             goto out_uninit_page_table;
>>> +#endif
>>
>> Why are these mappings *needed*?  I thought we only actually used these
>> fixup stacks for some crazy iret-to-userspace handling.  We're certainly
>> not doing that from KVM context.
>>
>> Am I forgetting something?
>>
>>> +#ifdef CONFIG_VMAP_STACK
>>> +     /*
>>> +      * Interrupt stacks are vmap'ed with guard pages, so we need to
>>> +      * copy mappings.
>>> +      */
>>> +     for_each_possible_cpu(cpu) {
>>> +             stack = per_cpu(hardirq_stack_ptr, cpu);
>>> +             pr_debug("IRQ Stack %px\n", stack);
>>> +             if (!stack)
>>> +                     continue;
>>> +             rv = kvm_copy_ptes(stack - IRQ_STACK_SIZE, IRQ_STACK_SIZE);
>>> +             if (rv)
>>> +                     goto out_uninit_page_table;
>>> +     }
>>> +
>>> +#endif
>>
>> I seem to remember that the KVM VMENTRY/VMEXIT context is very special.
>>   Interrupts (and even NMIs?) are disabled.  Would it be feasible to do
>> the switching in there so that we never even *get* interrupts in the KVM
>> context?
> 
> That would be nicer.
> 
> Looking at this code, it occurs to me that mapping the IRQ stacks
> seems questionable.  As it stands, this series switches to a normal
> CR3 in some C code somewhere moderately deep in the APIC IRQ code.  By
> that time, I think you may have executed traceable code, and, if that
> happens, you lose.  i hate to say this, but any shenanigans like this
> patch does might need to happen in the entry code *before* even
> switching to the IRQ stack.  Or perhaps shortly thereafter.
>
> We've talked about moving context tracking to C.  If we go that route,
> then this KVM context mess could go there, too -- we'd have a
> low-level C wrapper for each entry that would deal with getting us
> ready to run normal C code.
> 
> (We need to do something about terminology.  This kvm_mm thing isn't
> an mm in the normal sense.  An mm has normal kernel mappings and
> varying user mappings.  For example, the PTI "userspace" page tables
> aren't an mm.  And we really don't want a situation where the vmalloc
> fault code runs with the "kvm_mm" mm active -- it will totally
> malfunction.)
> 

One of my next step is to try to put the KVM page table in the PTI userspace
page tables, and not switch CR3 on KVM_RUN ioctl. That way, we will run with
a regular mm (but using the userspace page table). Then interrupt would switch
CR3 to kernel page table (like paranoid idtentry currently do it).

alex.




