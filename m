Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E921C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 227E9208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:06:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="snV2Nlrm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 227E9208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C16886B000A; Tue, 14 May 2019 04:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA0966B000C; Tue, 14 May 2019 04:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1B2B6B000D; Tue, 14 May 2019 04:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 661346B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:06:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c12so11469352pfb.2
        for <linux-mm@kvack.org>; Tue, 14 May 2019 01:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=B0Y+NEwWZFt6JvGfM9bAxeiqnPSo8BnTeZpdh3Z+JGM=;
        b=OAbUufyMYTE9FGVxu3QPhTnDirS/Y3Hu0H/AD/Ei551ZCiW5hm7juYH4cnBrXzFSmZ
         avAS8XXhbK6oTRcWFI9jQT/jNRNRfsinxdhbQGbeWOqeKrxYakharKm4qZZuWFVcyc+q
         U1HfTyAg21o3gFptzn5m5PEls2qCA72hI8K0gI7X7UHFW12C3TtwoHN5OIr8jPAWy17e
         xrfO9soR+vdxvQLhMT2C5J8ptNr5EXZiOT3YnMh93RgrcGAg8sE8iQGLwDR8S8eSlHAU
         /Dinr2aNAiNv0OwJ7sqaoJUaix6yQ8cIiAGxSXDBrrAVjUm00WGvuNfU9OMWTP1sNzwW
         Wflg==
X-Gm-Message-State: APjAAAVSpALPP3PmapaXw3wrUe+L5FLuLSMg9TXrGiuzdN7gFztEb9BU
	t3MqvKeicw27zrrkUx17i3AjNWmSgjPKbCWDptleQf54VgmIRJulRQiL2KDK1GqwTpHswD4zn2+
	wKnpHE8dVw3Nlg9e3zE1Uyjd92iJ3MJ4mvWmUhnGIdqLf5Q8wOeHWAV6r4tz0I4FBiw==
X-Received: by 2002:a17:902:4827:: with SMTP id s36mr13439928pld.197.1557821173064;
        Tue, 14 May 2019 01:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhhjfkvyX2jl9rrPKsSeXn6Pc4l8CTN+9aPV77M6bDQkgfqn6lBkABwQhoQYnXUXAqZAii
X-Received: by 2002:a17:902:4827:: with SMTP id s36mr13439857pld.197.1557821172145;
        Tue, 14 May 2019 01:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557821172; cv=none;
        d=google.com; s=arc-20160816;
        b=zIX1AYd+V/7l5PrIpQhBXe5+1pdzhx8+/4Nh40lecTDASHo8upXwhyONAd0xG7NZC7
         Gn1jXsHlm3CqJuyN6XxcP8A8B0/TskvxSKRHE7HDN0Ghay0bVfr+arKzq+GUNcC+Thsg
         UqOGwp3THAIdPpx+MawMnPyt1PItIEC4NZb/LM1OIpnplA6aXR5kbV8zYDXWo09Jnj50
         oSgmTNb/TDQWy0VHVFInjVC7gItB6qatlYqyGVmHcaDRdnZPPn3YXtplfurR1gVWG9d3
         ZxfG+K1gU0KYLe53aR5SsskcJJm4CeZayYZLc1jtknYDi0x3nd9YxniWIEVKtjwxZAiK
         w7ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=B0Y+NEwWZFt6JvGfM9bAxeiqnPSo8BnTeZpdh3Z+JGM=;
        b=dlXGn+TIkfOQYBOX3ZUrOCXq9HLY3UxidPz7x0JHCe5lRHjO6DT1SEBsOx0orGx5/U
         3iqLTmX3cj89Ay6pcdy5e+OMynw2jB3770eFtDehIvkcO83LBYswlCm+08mAPZRVA/2/
         Si53e7X8y3wWteKUpKX6xo5Q5u0im7v8nRkfFpovjsX13fyxXDGYY44nUkEyCCRHSZNP
         Fk6hAcf+pyYeWh68BODwBBm14agP9RYWaBWNZKEAsV9S/sDX3zSK9Wjljq4PTnph6qd3
         ma1lKxpafS1GgCCIkV60P/cF7CkwYV1bmF09EQYLBqF+6MBzM3qnD097EK8PBpvm4nxr
         igHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=snV2Nlrm;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 17si20161996pgt.554.2019.05.14.01.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 01:06:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=snV2Nlrm;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E7xP2K031699;
	Tue, 14 May 2019 08:05:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=B0Y+NEwWZFt6JvGfM9bAxeiqnPSo8BnTeZpdh3Z+JGM=;
 b=snV2NlrmriYM5JjJRsJw7giHlgdfVylr/v61et/3DktkJgcHN5UfhEof1Xmmjbcqmiqy
 xORAFW1lWLC1DZTvC9mTKnoy0PKAOnVMmxl2Ox3GahdUrMV17UgmQ+m/qN4+x6l4kcIH
 IbEKSsVLZ2OP1KHNwRBajhd0QaCJkK1FlXcrE6mY3ktTB+IgYCkGsJQgberUZIcAp0Sp
 8BVyOMEHqNlUrSwjdYIhsQa+BzohRTzTtxxZCUurg6MBBiNbMVBCM+QOQtmSPp/z9EXW
 27cyT3jm7MzGAGXtApRgbzLpnWfeq0d0ZLXMptIVEhrdn8eHUXjzeVq5nu/UrxCDsKLj 6Q== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2sdq1qbycj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:05:52 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E84ATh150192;
	Tue, 14 May 2019 08:05:52 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2sf3cn47q9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:05:52 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4E85osk015007;
	Tue, 14 May 2019 08:05:50 GMT
Received: from [10.0.5.57] (/213.57.127.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 01:05:50 -0700
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
Date: Tue, 14 May 2019 11:05:44 +0300
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>,
        X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1BFC571D-6C85-409C-8FD3-1E34559A277D@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
 <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
To: Andy Lutomirski <luto@kernel.org>
X-Mailer: Apple Mail (2.3445.4.7)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140059
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140059
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 14 May 2019, at 5:07, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> On Mon, May 13, 2019 at 2:09 PM Liran Alon <liran.alon@oracle.com> =
wrote:
>>=20
>>=20
>>=20
>>> On 13 May 2019, at 21:17, Andy Lutomirski <luto@kernel.org> wrote:
>>>=20
>>>> I expect that the KVM address space can eventually be expanded to =
include
>>>> the ioctl syscall entries. By doing so, and also adding the KVM =
page table
>>>> to the process userland page table (which should be safe to do =
because the
>>>> KVM address space doesn't have any secret), we could potentially =
handle the
>>>> KVM ioctl without having to switch to the kernel pagetable (thus =
effectively
>>>> eliminating KPTI for KVM). Then the only overhead would be if a =
VM-Exit has
>>>> to be handled using the full kernel address space.
>>>>=20
>>>=20
>>> In the hopefully common case where a VM exits and then gets =
re-entered
>>> without needing to load full page tables, what code actually runs?
>>> I'm trying to understand when the optimization of not switching is
>>> actually useful.
>>>=20
>>> Allowing ioctl() without switching to kernel tables sounds...
>>> extremely complicated.  It also makes the dubious assumption that =
user
>>> memory contains no secrets.
>>=20
>> Let me attempt to clarify what we were thinking when creating this =
patch series:
>>=20
>> 1) It is never safe to execute one hyperthread inside guest while =
it=E2=80=99s sibling hyperthread runs in a virtual address space which =
contains secrets of host or other guests.
>> This is because we assume that using some speculative gadget (such as =
half-Spectrev2 gadget), it will be possible to populate *some* CPU core =
resource which could then be *somehow* leaked by the hyperthread running =
inside guest. In case of L1TF, this would be data populated to the L1D =
cache.
>>=20
>> 2) Because of (1), every time a hyperthread runs inside host kernel, =
we must make sure it=E2=80=99s sibling is not running inside guest. i.e. =
We must kick the sibling hyperthread outside of guest using IPI.
>>=20
>> 3) =46rom (2), we should have theoretically deduced that for every =
#VMExit, there is a need to kick the sibling hyperthread also outside of =
guest until the #VMExit is completed. Such a patch series was =
implemented at some point but it had (obviously) significant performance =
hit.
>>=20
>>=20
> 4) The main goal of this patch series is to preserve (2), but to avoid
> the overhead specified in (3).
>>=20
>> The way this patch series achieves (4) is by observing that during =
the run of a VM, most #VMExits can be handled rather quickly and locally =
inside KVM and doesn=E2=80=99t need to reference any data that is not =
relevant to this VM or KVM code. Therefore, if we will run these =
#VMExits in an isolated virtual address space (i.e. KVM isolated address =
space), there is no need to kick the sibling hyperthread from guest =
while these #VMExits handlers run.
>=20
> Thanks!  This clarifies a lot of things.
>=20
>> The hope is that the very vast majority of #VMExit handlers will be =
able to completely run without requiring to switch to full address =
space. Therefore, avoiding the performance hit of (2).
>> However, for the very few #VMExits that does require to run in full =
kernel address space, we must first kick the sibling hyperthread outside =
of guest and only then switch to full kernel address space and only once =
all hyperthreads return to KVM address space, then allow then to enter =
into guest.
>=20
> What exactly does "kick" mean in this context?  It sounds like you're
> going to need to be able to kick sibling VMs from extremely atomic
> contexts like NMI and MCE.

Yes that=E2=80=99s true.
=E2=80=9Ckick=E2=80=9D in this context will probably mean sending an IPI =
to all sibling hyperthreads.
This IPI will cause these sibling hyperthreads to exit from guest to =
host on EXTERNAL_INTERRUPT
and wait for a condition that again allows to enter back into guest.
This condition will be once all hyperthreads of CPU core is again =
running only within KVM isolated address space of this VM.

-Liran



