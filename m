Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0431CC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE739208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:58:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Qa00vacP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE739208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 518AD6B0007; Tue, 14 May 2019 03:58:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C96C6B0008; Tue, 14 May 2019 03:58:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B7EE6B000A; Tue, 14 May 2019 03:58:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 004496B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:58:28 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h14so10949143pgn.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:58:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=APVvqr1lJvph+nzc+bHSkxPBxoL6T6+MikT3VYcFYTY=;
        b=Rn1EYn6tCR/0FtgdxeZW2Ta1ZW3RC6JUK2xlRcXztmxUezfwPbFy4nzfD8VgkkQ5BA
         Ikz3lDgHVfXmvv4f42mc7/ztlydGGlIRCzhs98p+UYChUOVVZwnjJPId87zeIZc+um6q
         CZLyGwipFDp4mePbyzz5cDk5S5t+0BOCWLpcDSmEp400mVG5ORfnoPqzUIB3I/rF7PoC
         kbJA2Z4uTNhr2I18oXnpE35XXqOjolR6MtY0wMWyKdMRolSq94klGnJ6wfTz0v78tuKj
         js/GD3RhCQuTqYTmRMtsyKZMG/CnyboX4OxZkRtVbnKoRq27Q0B//oap4Z+ZZwopveUH
         TYoQ==
X-Gm-Message-State: APjAAAVN/0MLj9MVNTKYmTgpXwzDwl7+RsR8vk8kjnd8avNy92z1qr8c
	qpe7KuO/ki34uYK/bZnR0zX19KpCD5L4HqNnBlCt2/zRKbZy/7wt07ddSO3etlMP7BLFyYwzUCv
	PFV7jnXncj4u1w00KZTlWVaAVfj4oz0Jj9LSlT9k2iD1pYNj2ae8u/8Vz77OfPE29Hw==
X-Received: by 2002:a63:3182:: with SMTP id x124mr35719792pgx.364.1557820707541;
        Tue, 14 May 2019 00:58:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaSB7unBjQ7LXqrPDDJl4gVB6UAp6H4ShzfiIbmXQECs7cMRAY7h6jfSC92l6/bZX4eQRX
X-Received: by 2002:a63:3182:: with SMTP id x124mr35719757pgx.364.1557820706824;
        Tue, 14 May 2019 00:58:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557820706; cv=none;
        d=google.com; s=arc-20160816;
        b=T2o32jgLv3v1wlWhtaGMFFGrd5Epr1xclY/qQpE5RE3GAZyQ1wxgxNQVOGWpVs/h95
         3FGi0IQ9uTBJ4aGBVZ2GSpZp9YFM/Wqz+Bo6xRdNQsnc5cqYKJCX8thwohj3lmKgGpeZ
         LVdhGvd+Asb2AQoBQZzfYL5C3qYVSTe3vKmPAw8SKoXSck7AK4IbH53YLqOGuxGXsbq8
         /VpXqiIrOmmPsPSnMbQev3sKDMOT63okqSZVDgkyZSqk73W8Ee/3iIjDWYp987G8mGDI
         paaTl+q4FAI/dTILqo8dJrC0bbstjdoy1oDchcbF3g7ZgsaPrXT/LGsYBuVWZXdIOYZ4
         /2+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=APVvqr1lJvph+nzc+bHSkxPBxoL6T6+MikT3VYcFYTY=;
        b=L88pfAT4TJZPcarouCJeODGRFdmofhIjRBUQB8aEOqeBvi80rM+Toc3oYNz7dNVP4I
         T6BmoAuJ7WUeByGlIaYX2h9KPiZwiXVginC0aH3jzGHYW2Zh3Ps1EuNhE7OtBSiF+zBb
         YQxwk7RMi8shAJvpvYXTjd9aRmWa9edwoJJEZV9x0SB348eRa2hHPGpNadqfDxHoYnLw
         8idRa0WA2kNiP7fwbXYBLe5qG4g+1bLxLS8IR5nYORiHLwl7jFNtJPMXNlelUbLOBACv
         ZlilRfa+ksWw0Z7qicqEfJbGo/8JIBSQgPYu/dV23CE8S+Y1yw2ttWAf538MkgcHUMFQ
         dUPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Qa00vacP;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t34si11083969pgm.396.2019.05.14.00.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 00:58:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Qa00vacP;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E7rZFV025235;
	Tue, 14 May 2019 07:58:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=APVvqr1lJvph+nzc+bHSkxPBxoL6T6+MikT3VYcFYTY=;
 b=Qa00vacPoKAcDmadtKFTWQ86hpzpK8edI+E8nptO4qmbHNiluW4rA72QRsqn8dqQgb+H
 YGHr2ncstXf+JbqVMohLL2958KIfwz1ytfCJ7tbXXGN1fYU2kBNJ1BY7oD907Cqwg837
 A61+vFfLiLoFKI7Ug++Agy45D9NhL2tIeOvullD7o5jCeYuuFEqelfAWsJg31pIUxGK3
 zAykOuGR1A4gFP7D39sMxyz/OAWKeBzSF37EeCYYD6w2+diBlhHO4t4uR/f89UX7hgse
 NPu/z0kCRo8ZxHnDBqoSzEiQzVrR8NVl4GGZs4KQwlhUmJ6N7g8nenjrZc4sJIEKLJad cQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2sdkwdm73v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 07:58:08 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E7vKet144428;
	Tue, 14 May 2019 07:58:08 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2sdmeax9xs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 07:58:08 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4E7w7PM008960;
	Tue, 14 May 2019 07:58:07 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 00:58:07 -0700
Subject: Re: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
        Jonathan Adams <jwadams@google.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
 <64c49aa6-e7f2-4400-9254-d280585b4067@oracle.com>
 <CALCETrUd2UO=+JOb_008mGbPdfW5YJgQyw5H7D_CxOgaWv=gxw@mail.gmail.com>
 <20190514070719.GD2589@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <b17d8525-a83b-d37b-dfb4-f09ec3b6bcfc@oracle.com>
Date: Tue, 14 May 2019 09:58:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190514070719.GD2589@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140058
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/14/19 9:07 AM, Peter Zijlstra wrote:
> On Mon, May 13, 2019 at 11:13:34AM -0700, Andy Lutomirski wrote:
>> On Mon, May 13, 2019 at 9:28 AM Alexandre Chartre
>> <alexandre.chartre@oracle.com> wrote:
> 
>>> Actually, I am not sure this is effectively useful because the IRQ
>>> handler is probably faulting before it tries to exit isolation, so
>>> the isolation exit will be done by the kvm page fault handler. I need
>>> to check that.
>>>
>>
>> The whole idea of having #PF exit with a different CR3 than was loaded
>> on entry seems questionable to me.  I'd be a lot more comfortable with
>> the whole idea if a page fault due to accessing the wrong data was an
>> OOPS and the code instead just did the right thing directly.
> 
> So I've ran into this idea before; it basically allows a lazy approach
> to things.
> 
> I'm somewhat conflicted on things, on the one hand, changing CR3 from
> #PF is a natural extention in that #PF already changes page-tables (for
> userspace / vmalloc etc..), on the other hand, there's a thin line
> between being lazy and being sloppy.
> 
> If we're going down this route; I think we need a very coherent design
> and strong rules.
> 

Right. We should particularly ensure that the KVM page-table remains a
subset of the kernel page-table, in particular page-table changes (e.g.
for vmalloc etc...) should happen in the kernel page-table and not in
the kvm page-table.

So we should probably enforce switching to the kernel page-table when
doing operation like vmalloc. The current code doesn't enforce it, but
I can see it faulting, when doing any allocation (because the kvm page
table doesn't have all structures used during an allocation).

alex.

