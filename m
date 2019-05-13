Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A739DC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FFED20675
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zVO+GlBr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FFED20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3B806B0010; Mon, 13 May 2019 17:17:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEC766B0266; Mon, 13 May 2019 17:17:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8C9A6B0269; Mon, 13 May 2019 17:17:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 807D76B0010
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:17:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m12so7647342pls.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=1GFcZnns0Tye3s9BjptvblFnxNEbKJNIwuyvnb9h4hU=;
        b=sJNU8le3z/DnowovLeAgEQOa7Nr1TVNuqOvz6XLt5oAmElipavTEKqyhAtReeWf2zL
         74HffkI5xXZqne6qnCiMLM2Gnn2Z0sWkkHiSEwC+sJ77pd4VDWfdMcuzI/8HaN/jmN2M
         VU7Q8bJ5q8i2u/79/TsKYoPJm3dotAm+XKBJMicsoE/ey4Q3TggAa4lxcG+Lrd4MIuwt
         lXJ8pNM5w3kebGsy5HX5P+3JYob2bTNUm2wcqGJPvj1NhlvwWW6ys3bGnZdqtVaigvRK
         Ex0B0gdy8+a45wJ3xEesQvbB8c248ihwxcr8edFkliB1dqh1VkEw32zQ7d8UuGJUjmnw
         AS1w==
X-Gm-Message-State: APjAAAXhcq1y4bN0u1nkXZvdu2Np5Z3xA00aBwSX99e1xyv68yvMf8P7
	rYfNYdUdshd8bgL4vqgUdpLpgJfMhfjw5z7oPFj5s2ZSF47MMjIKrdar+D7RlHW2kI1qUvsfhlf
	0ieI9bS2ZMut5Al4QZ8koNf2GD2nwerhVhoGto7GL7wLHHKzrw6RZ9dM3YonA/qT0ng==
X-Received: by 2002:a63:1e5b:: with SMTP id p27mr33226069pgm.213.1557782220991;
        Mon, 13 May 2019 14:17:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhpl8Ypx9IAxGHQhl0wtefnx4KSCSQBnn0A+3a8oF2bWMUfR2WVWImtfN9+/trx1FdBq+8
X-Received: by 2002:a63:1e5b:: with SMTP id p27mr33226012pgm.213.1557782220176;
        Mon, 13 May 2019 14:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557782220; cv=none;
        d=google.com; s=arc-20160816;
        b=DlUoZy1LY259S/3yMNT940q7B0d9WJ/lrgv7Ia0mYAJO2Z/yo8f6Aueft5YtzqroT6
         0d1FpN6hKvR1jx4q+hMUNFGvzP3Dy6UEbtlRS6HE1FkgN+9VgrSUtfQGPwVIqBPHSSav
         NihQIlo/YweXjir+w7FqqELlaGWDukCaKX99vsO+UfyOFEAcZK+8yMbSiz9OnhViI4dQ
         mI4aNSxKbx0ElEWx7MEsmCZvC+aLmDQ2T/9x4aoqA98cwo4+FDznyway/lFws6IMs3/J
         cyntx2FQbxn6sc8KGW210tiUk7ZS5vETaj9FP37xjXn6hZ/OTDh3p7TWiYB+LkXJrAhr
         YRjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=1GFcZnns0Tye3s9BjptvblFnxNEbKJNIwuyvnb9h4hU=;
        b=A5oMrJ3/KsBfpK7qjdyW9x3VUQRrn+xn8tK/0+26GwYFj7YCGvuIOwybM7k8AraOpP
         a9ViiqJOFMvqQI6UPfUByq92zl9fa8nmADB48ZvNN1nmdSW9LwsYZEf+tfgivBMTLVPz
         LCG0xVU0mjWlBpn7YuM69uwTbN5rTLv6kqvovYgN681yTcDCrs9TMCpLFoPvZWcG4zJw
         PISi6ZZ3lijIf1uNg0lW2pMwLUlekVYHV/Hzh51kcZmnuDhY82qQpbzukyv0rpnslH98
         3NWYRIZ+gLHPMIOAvQ1JJ0PFR/u0GVMIUywZ3XD+HSbuSqarYLylCayz2YjTc1GaHNIG
         AAkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zVO+GlBr;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id bg9si12771280plb.12.2019.05.13.14.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 14:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zVO+GlBr;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DL8tr1138636;
	Mon, 13 May 2019 21:16:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=1GFcZnns0Tye3s9BjptvblFnxNEbKJNIwuyvnb9h4hU=;
 b=zVO+GlBrPrU9pxKuw86PVJPFyTMWTsRfnNIKm7C8ze2lA9cH1Gwr443hpWemoTjIyChb
 IrjLqtFmalUVLJg0NT1t827pdWkxzp8Gg0c2/+VTKFhdCB3geQieQO6J73C7n0fuTJtC
 snXBPpv+T5AAyML+vDGF2EkPMX1Ak4rmm3yf/v2lq6tviHGNruBaAWO8js+kSKoXl5Ql
 sWXU6NenoyIBs7kuwsyF1N5bJNOj3b6dqYomaZ6zdGNsc8Pc8D1WZXDWknZmjl7XrIoE
 Tx3K723FHXLrEcifd2A+8mBkiRo9hZ8hnia43nEUIYWc2EkiRRDaRU2HCSpHi4XOQKCV 5Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sdntthuby-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 21:16:38 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DLFFWS074151;
	Mon, 13 May 2019 21:16:37 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2sdmeaqdyq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 21:16:37 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4DLGZLw007021;
	Mon, 13 May 2019 21:16:35 GMT
Received: from [192.168.14.112] (/79.180.238.224)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 14:16:34 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <11F6D766-EC47-4283-8797-68A1405511B0@intel.com>
Date: Tue, 14 May 2019 00:16:28 +0300
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        "pbonzini@redhat.com" <pbonzini@redhat.com>,
        "rkrcmar@redhat.com" <rkrcmar@redhat.com>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>,
        "hpa@zytor.com" <hpa@zytor.com>,
        "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
        "luto@kernel.org" <luto@kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
        "jan.setjeeilers@oracle.com" <jan.setjeeilers@oracle.com>,
        "jwadams@google.com" <jwadams@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <46FF68B2-3284-4705-A904-328992449D43@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <11F6D766-EC47-4283-8797-68A1405511B0@intel.com>
To: "Nakajima, Jun" <jun.nakajima@intel.com>
X-Mailer: Apple Mail (2.3445.4.7)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130141
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 13 May 2019, at 22:31, Nakajima, Jun <jun.nakajima@intel.com> =
wrote:
>=20
> On 5/13/19, 7:43 AM, "kvm-owner@vger.kernel.org on behalf of Alexandre =
Chartre" wrote:
>=20
>    Proposal
>    =3D=3D=3D=3D=3D=3D=3D=3D
>=20
>    To handle both these points, this series introduce the mechanism of =
KVM
>    address space isolation. Note that this mechanism completes (a)+(b) =
and
>    don't contradict. In case this mechanism is also applied, (a)+(b) =
should
>    still be applied to the full virtual address space as a =
defence-in-depth).
>=20
>    The idea is that most of KVM #VMExit handlers code will run in a =
special
>    KVM isolated address space which maps only KVM required code and =
per-VM
>    information. Only once KVM needs to architectually access other =
(sensitive)
>    data, it will switch from KVM isolated address space to full =
standard
>    host address space. At this point, KVM will also need to kick all =
sibling
>    hyperthreads to get out of guest (note that kicking all sibling =
hyperthreads
>    is not implemented in this serie).
>=20
>    Basically, we will have the following flow:
>=20
>      - qemu issues KVM_RUN ioctl
>      - KVM handles the ioctl and calls vcpu_run():
>        . KVM switches from the kernel address to the KVM address space
>        . KVM transfers control to VM (VMLAUNCH/VMRESUME)
>        . VM returns to KVM
>        . KVM handles VM-Exit:
>          . if handling need full kernel then switch to kernel address =
space
>          . else continues with KVM address space
>        . KVM loops in vcpu_run() or return
>      - KVM_RUN ioctl returns
>=20
>    So, the KVM_RUN core function will mainly be executed using the KVM =
address
>    space. The handling of a VM-Exit can require access to the kernel =
space
>    and, in that case, we will switch back to the kernel address space.
>=20
> Once all sibling hyperthreads are in the host (either using the full =
kernel address space or user address space), what happens to the other =
sibling hyperthreads if one of them tries to do VM entry? That VCPU will =
switch to the KVM address space prior to VM entry, but others continue =
to run? Do you think (a) + (b) would be sufficient for that case?

The description here is missing and important part: When a hyperthread =
needs to switch from KVM isolated address space to kernel full address =
space, it should first kick all sibling hyperthreads outside of guest =
and only then safety switch to full kernel address space. Only once all =
sibling hyperthreads are running with KVM isolated address space, it is =
safe to enter guest.

The main point of this address space is to avoid kicking all sibling =
hyperthreads on *every* VMExit from guest but instead only kick them =
when switching address space. The assumption is that the vast majority =
of exits can be handled in KVM isolated address space and therefore do =
not require to kick the sibling hyperthreads outside of guest.

-Liran

>=20
> ---
> Jun
> Intel Open Source Technology Center
>=20
>=20

