Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81889C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A60120862
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:34:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="47ccYNEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A60120862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E65E6B0005; Tue, 14 May 2019 17:34:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BC226B0006; Tue, 14 May 2019 17:34:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AA6E6B0007; Tue, 14 May 2019 17:34:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE406B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:34:01 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id o126so460849itc.5
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xP/1J7WtSjWfHwARbyhttwinIWyTQ+wkt13il4qJ3gI=;
        b=VIp/4InC1/VIGf0OX40HVZ1MXDRPP+z6VgGVkwgPBcIphVYa1OB4eId58HWYHLd1mu
         79W8IJJITvtTH3cFGC+rv5+AOB3yhVMtiEdRqQbEOeo32SCj8DLE+NUvUQVqlJzDnGfT
         4n+jnGO8P5NDN0bVZbiXSa/UOhq3WCqoPo+O7gClntTON/Fj5N7DXnw8fN3u+WxyN3Z+
         8rqNhWXAgsQ4XSpfHzNcXLzXU6iY8sBPocBhIEaLKSILmUn6+vSvdP5ooeGX2Ftk+n87
         cugTqfApU5DcFlzj1mUXomO5wjBUcMtpJxXuLlgga0ZfnAJss6Yc7ERvHhYCbpHg80JC
         p1WA==
X-Gm-Message-State: APjAAAX3Ij3W+4kaIUMNRnCjU/azL7pgHa42LbqsdKfJvq8YWO6fGszg
	elu3kPy1B4vJihFMjqW1/0ZZ9yw9UPZOQzTUCtMiUPhmdhGHAVlDo38LWhLcfiSXEn+gLP/m5Cu
	BAY+xHrj6MNjR7ZM6u892fteISq1uDObDcLI/b65UhpSFPgkKcgtENL95q36+SvpSLA==
X-Received: by 2002:a02:8243:: with SMTP id q3mr26325294jag.37.1557869641010;
        Tue, 14 May 2019 14:34:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhwR3jAIh7twvQuKyTzPyGKGQw4xyCOpuFSt/c3LEV2qHWhqnysAY68XvoO5Ug8JEPklRQ
X-Received: by 2002:a02:8243:: with SMTP id q3mr26325233jag.37.1557869640272;
        Tue, 14 May 2019 14:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557869640; cv=none;
        d=google.com; s=arc-20160816;
        b=A/CkXeQMJKePZTkWw0tzDrYBtvcSS7aiEUuYxKQk8DrjPTVCQjU/jaqcwHdccY/Fv0
         ujl3YrUCk+iFScIHHcglkqD1/U8l951GZFC31ytelw34VbXi+N2IqG7Lqdv9/34O4ccM
         qw7f6Ho9tdAHWYhbkLHVm4/HPtXfS/QAE3NlHePBpkUBszVaTL9eGK4cvVDSA4GQzNpM
         +xqFQrbfcqjDhNGm2R6zmHOw08ndZwsy4epLOcsR6EF3Aee9aIdZVPe83Vk82QKoBLzB
         9p63RBAQAWIYN9Rd6UTsszAc8Eod9Sa+yT4wACimKcfFerojRHDRZ2IyBTDu8O0z8uzf
         2jQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=xP/1J7WtSjWfHwARbyhttwinIWyTQ+wkt13il4qJ3gI=;
        b=pKjxbDFlB5glx4pmi7WCLlr3IMCn3HyKsNYPqIHGwrKVSh3Sdc/U+LD6iz5ARwY1FR
         UzHuYEi8WLat+RrM2QGQcIl65ixMop2kDDjMAh3kYxxTTd5yLArCM624c1klEmLNTm6W
         OC7zj7nkOOH9ihPQWftqkRCzEk4GlO7v8H2E7roDbXK1VaGB5Xie2AgNdI5fwvChWHBS
         EEZ3hPFxcr0MoDn2KhYMGh/9yvkYtGtDyePnAEVoEuPQ9duEXy0ioFGA723Ve4jLEwvv
         Om6D8g7eml2g0hxcWe6Kn/nFzsbtdoZ9dSIlHyWP3bXTJ1GaUNOxXUATLZUfC2NPyUYz
         WqqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=47ccYNEq;
       spf=pass (google.com: domain of jan.setjeeilers@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jan.setjeeilers@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k13si99018jah.101.2019.05.14.14.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:34:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jan.setjeeilers@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=47ccYNEq;
       spf=pass (google.com: domain of jan.setjeeilers@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jan.setjeeilers@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ELTuN4172625;
	Tue, 14 May 2019 21:33:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=xP/1J7WtSjWfHwARbyhttwinIWyTQ+wkt13il4qJ3gI=;
 b=47ccYNEqQtVdANjxK2ZSYU7cWNuAlIz3aclJ+JlSKO3kyibmZMxV9F6hNHWk0nBOHcbb
 eWoQul25jc0gcFPtlbko4rrYqrREgGZxtpPLXG+i/YeKLpFuLDUeokwnqYBB2qCtSNz3
 n5GK/gjgh4cWNyP6cfMyo9WMLR6aQ7zSSgyJDUk8AJALjqOPZlLWOlQki9atZU9VDhr9
 Qn4ylmgTtHrOsereilhau+nW9/JOENdESqjcKGLL1qpoBBUHdB6RlPVmd1LTdTO3De5N
 ZVt/mvsOGNsVYibT/I71ekgHlRyFq9Psav9nBhMdCN+wxzdalYAQvQWL67Mg41xLS0di 2g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2sdq1qgvua-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 21:33:37 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ELVIfq134876;
	Tue, 14 May 2019 21:31:37 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2sdmebbr4s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 21:31:37 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4ELVR6l014023;
	Tue, 14 May 2019 21:31:32 GMT
Received: from tresor.us.oracle.com (/10.211.52.98)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 14:31:27 -0700
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>
Cc: Liran Alon <liran.alon@oracle.com>,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
 <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
 <20190514073738.GH2589@hirez.programming.kicks-ass.net>
From: Jan Setje-Eilers <jan.setjeeilers@oracle.com>
Message-ID: <f0d218f1-076e-e8ce-ebf8-84712a126b32@oracle.com>
Date: Tue, 14 May 2019 14:32:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190514073738.GH2589@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=878
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140141
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=903 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 12:37 AM, Peter Zijlstra wrote:
> On Mon, May 13, 2019 at 07:07:36PM -0700, Andy Lutomirski wrote:
>> On Mon, May 13, 2019 at 2:09 PM Liran Alon <liran.alon@oracle.com> wrote:
>>> The hope is that the very vast majority of #VMExit handlers will be
>>> able to completely run without requiring to switch to full address
>>> space. Therefore, avoiding the performance hit of (2).
>>> However, for the very few #VMExits that does require to run in full
>>> kernel address space, we must first kick the sibling hyperthread
>>> outside of guest and only then switch to full kernel address space
>>> and only once all hyperthreads return to KVM address space, then
>>> allow then to enter into guest.
>> What exactly does "kick" mean in this context?  It sounds like you're
>> going to need to be able to kick sibling VMs from extremely atomic
>> contexts like NMI and MCE.
> Yeah, doing the full synchronous thing from NMI/MCE context sounds
> exceedingly dodgy, howver..
>
> Realistically they only need to send an IPI to the other sibling; they
> don't need to wait for the VMExit to complete or anything else.
>
> And that is something we can do from NMI context -- with a bit of care.
> See also arch_irq_work_raise(); specifically we need to ensure we leave
> the APIC in an idle state, such that if we interrupted an APIC sequence
> it will not suddenly fail/violate the APIC write/state etc.
>
  I've been experimenting with IPI'ing siblings on vmexit, primarily 
because we know we'll need it if ASI turns out to be viable, but also 
because I wanted to understand why previous experiments resulted in such 
poor performance.

  You're correct that you don't need to wait for the sibling to come out 
once you send the IPI. That hardware thread will not do anything other 
than process the IPI once it's sent. There is still some need for 
synchronization, at least for the every vmexit case, since you always 
want to make sure that one thread is actually doing work while the other 
one is held. I have this working for some cases, but not enough to call 
it a general solution. I'm not at all sure that the every vmexit case 
can be made to perform for the general case. Even the non-general case 
uses synchronization that I fear might be overly complex.

  For the cases I do have working, simply not pinning the sibling when 
we exit due to the quest idling is a big enough win to put performance 
into a much more reasonable range.

  Base on this, I believe that pining a sibling HT in a subset of cases, 
when we interact with full kernel address space, is almost certainly 
reasonable.

-jan

