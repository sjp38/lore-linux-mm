Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C2FC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 09:42:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B59C02147A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 09:42:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="s5uOWBty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B59C02147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233206B0271; Tue, 14 May 2019 05:42:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BE0B6B0272; Tue, 14 May 2019 05:42:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0607A6B0273; Tue, 14 May 2019 05:42:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD90D6B0271
	for <linux-mm@kvack.org>; Tue, 14 May 2019 05:42:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so11572741pff.11
        for <linux-mm@kvack.org>; Tue, 14 May 2019 02:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YGDQa1OkuMiXUV4tNUheY+38sI8XlHHOPmmUhcxpfkg=;
        b=OLwAKJGbunsUU0HYTVzvWelC9El1RVwW8S/TduiD5nf7nYWe5Do4QYusihyzS6jpqp
         UoqOMFxDuanE1ONEB37FgabBLoIVpmi4lDfdjJLHGoUJQcn096JtyC5VYi8SqFIoIXVg
         iozStgmiK0s2Uj78uPAMIVdaX+vnajZ2CVINVP6hRV3QOBUE5Nrhe0RFsjlQFtNJgbwU
         h+5Ftt3t0zkQFij+yTnOsBdSP0Yg/5NTlUA0wHiwR7HV+wgwV2C7abehkeE4+bLH/WpP
         oSX9X1ekZ+0jciZAdlPLdt0msXd+A2dQW+Nj+gsLBZ7kL1O7+vXAzxV8EGA2hkCQUO1a
         ZiNQ==
X-Gm-Message-State: APjAAAVjbocH9dB4GQMfS2xztygLH+BM5mMl8xi7Dkiieg4PWEvMhL6G
	U7dMD3y/bt8eFYJG0DuuQQAIT2rw5ZUrYMXiwb66JjEgnHwS2aME0EoRApNQmYrRS7EyMpWSbwX
	84G/32bG5M6aJHsuyPhy+KVVQb3iK66a9H3VSDiTeAbx6IMucoLh0lY0C29GZ9ysySQ==
X-Received: by 2002:a65:60cd:: with SMTP id r13mr22183927pgv.58.1557826937201;
        Tue, 14 May 2019 02:42:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZYsHiNVE0YceSH+5Akux6K5EXbQar6MEw/PIyhX2/gfxzJDwfyT64Y7jhWvKhk+VPBlkq
X-Received: by 2002:a65:60cd:: with SMTP id r13mr22183867pgv.58.1557826936300;
        Tue, 14 May 2019 02:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557826936; cv=none;
        d=google.com; s=arc-20160816;
        b=tgN87Dbw3uWNNa/5Msggr8jornDyEoM11WHXKF45io0XY/WCNBUj6uI/JLMVnhSOo0
         NsyrUTPLGw6Sf5TqqWTZZw9duF7afYg2L2yv5GBtGKJfeCsxqdhOx1prAJ1VNEchnYyQ
         MMbRaEIN8ryyWpr23KJKHqkc1DL/Jdg0g+zrkvZVN0xAVBwdjV44UmvkeQY0y0MuzCzj
         xJZ/cETDZDof8tpoytorZS44uAAaiDcf1VMMwkPF+WBmi4fAQa+dJgxnmSgUd6geiCes
         KOY8N5dx90eU/fqV+MvClsHr7H0zq0hvQExPv/lUMBZcQMf1DfHC/t2/XHSq3Vu4lddM
         wspw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=YGDQa1OkuMiXUV4tNUheY+38sI8XlHHOPmmUhcxpfkg=;
        b=F9CDQ6cTpERk9h8Cm91sLuY9B9qsVWZgp3/4Z/YQbxXNJC88kJVQgLZjlDo5Zg/eRl
         y3hPt1Ka0Q8EKdg8VC7sUf8IfAGm4XoEUFmiFlRRZ7QM0WHMfiF+8PeU0WFvRxQ3GWmy
         6vFNBetaVIv02+smymHuE6Nu2W/VfSKwlWUJOIjp18H/GkynJ1AY7ca7RnzF0CHVIxe4
         h5ou0aOlhv6KbRMUOIO2/bszFZbGDFkBPu5cqE5Bp+q1g2rIhk9xPWBqHzcdvCa2/FMS
         sQkqSlEXpYUV4HaEPKsLT2ZO+7gfFqqh19Bl4K0WuwDwNeIeS++Hqkpn/GBO6Z0aGx9z
         rorA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=s5uOWBty;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v4si448406pgr.475.2019.05.14.02.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 02:42:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=s5uOWBty;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E9cprn123136;
	Tue, 14 May 2019 09:41:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=YGDQa1OkuMiXUV4tNUheY+38sI8XlHHOPmmUhcxpfkg=;
 b=s5uOWBtyx5/VI95COzKSHJ/b/LVqo+7GlEl1DbKKVD33BRoJAKQq1nRPIAqjgas9q0L/
 mwMEaaJxbDV3Pf5hxsGOBzlfSwtaF2pgC1uPZdmOl/JvXhfVp+8TUwwxvgkCOxrplHWU
 77HLbDKF18hazfA1PjCoqLA3NFAGX43RJlzJRgbsEHbIyUgo/OIceeIiY+GaIr9y6Aa0
 DLq2s0dWRNoDJQRTcM9WJBbBqkFwCytNxeElFSr4bE1sbm2a0EjNlVGCJ7BtminobseM
 +i7Xa0HWfSx4EalKWyakdHJodZyFqpHs917sLRUUbOyKmNFELd29+Xu/claf3qQnx5yn aw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2sdkwdmwam-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 09:41:49 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E9fGlY003658;
	Tue, 14 May 2019 09:41:49 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2sdmeayt91-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 09:41:49 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4E9fkZN010996;
	Tue, 14 May 2019 09:41:46 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 02:41:45 -0700
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>,
        Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
 <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
Date: Tue, 14 May 2019 11:41:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140070
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140070
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 10:34 AM, Andy Lutomirski wrote:
> 
> 
>> On May 14, 2019, at 1:25 AM, Alexandre Chartre <alexandre.chartre@oracle.com> wrote:
>>
>>
>>> On 5/14/19 9:09 AM, Peter Zijlstra wrote:
>>>> On Mon, May 13, 2019 at 11:18:41AM -0700, Andy Lutomirski wrote:
>>>> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
>>>> <alexandre.chartre@oracle.com> wrote:
>>>>>
>>>>> pcpu_base_addr is already mapped to the KVM address space, but this
>>>>> represents the first percpu chunk. To access a per-cpu buffer not
>>>>> allocated in the first chunk, add a function which maps all cpu
>>>>> buffers corresponding to that per-cpu buffer.
>>>>>
>>>>> Also add function to clear page table entries for a percpu buffer.
>>>>>
>>>>
>>>> This needs some kind of clarification so that readers can tell whether
>>>> you're trying to map all percpu memory or just map a specific
>>>> variable.  In either case, you're making a dubious assumption that
>>>> percpu memory contains no secrets.
>>> I'm thinking the per-cpu random pool is a secrit. IOW, it demonstrably
>>> does contain secrits, invalidating that premise.
>>
>> The current code unconditionally maps the entire first percpu chunk
>> (pcpu_base_addr). So it assumes it doesn't contain any secret. That is
>> mainly a simplification for the POC because a lot of core information
>> that we need, for example just to switch mm, are stored there (like
>> cpu_tlbstate, current_task...).
> 
> I don’t think you should need any of this.
> 

At the moment, the current code does need it. Otherwise it can't switch from
kvm mm to kernel mm: switch_mm_irqs_off() will fault accessing "cpu_tlbstate",
and then the page fault handler will fail accessing "current" before calling
the kvm page fault handler. So it will double fault or loop on page faults.
There are many different places where percpu variables are used, and I have
experienced many double fault/page fault loop because of that.

>>
>> If the entire first percpu chunk effectively has secret then we will
>> need to individually map only buffers we need. The kvm_copy_percpu_mapping()
>> function is added to copy mapping for a specified percpu buffer, so
>> this used to map percpu buffers which are not in the first percpu chunk.
>>
>> Also note that mapping is constrained by PTE (4K), so mapped buffers
>> (percpu or not) which do not fill a whole set of pages can leak adjacent
>> data store on the same pages.
>>
>>
> 
> I would take a different approach: figure out what you need and put it in its
> own dedicated area, kind of like cpu_entry_area.

That's certainly something we can do, like Julian proposed with "Process-local
memory allocations": https://lkml.org/lkml/2018/11/22/1240

That's fine for buffers allocated from KVM, however, we will still need some
core kernel mappings so the thread can run and interrupts can be handled.

> One nasty issue you’ll have is vmalloc: the kernel stack is in the
> vmap range, and, if you allow access to vmap memory at all, you’ll
> need some way to ensure that *unmap* gets propagated. I suspect the
> right choice is to see if you can avoid using the kernel stack at all
> in isolated mode.  Maybe you could run on the IRQ stack instead.

I am currently just copying the task stack mapping into the KVM page table
(patch 23) when a vcpu is created:

	err = kvm_copy_ptes(tsk->stack, THREAD_SIZE);

And this seems to work. I am clearing the mapping when the VM vcpu is freed,
so I am making the assumption that the same task is used to create and free
a vcpu.


alex.

