Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEB00C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 627B6208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:58:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Cxu0Rbtn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 627B6208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 037F26B0003; Tue, 14 May 2019 03:58:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F297A6B0005; Tue, 14 May 2019 03:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF1476B0007; Tue, 14 May 2019 03:58:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A55016B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:58:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so2190558pfo.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:58:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Hm9Tm5LOAz3Yewu8iIsMrN/PygszNEAXdNiSHUZXasc=;
        b=HfXU9LbA8ygGYFLHYq0IaZhzU7A77zch32WchJ4SCmiFp7cqtblP9PJtyCktpPXVWP
         9OPptkBuOtq3L9Md6ByfhY+Jd+DIltgLtZvEljULPc7Y77uqRgQ0IteF9xkrfIFPYRUZ
         2QQP2pjkqcsSMfbgW1rInWLWK11vEzEsvavPOh2frUzIbAOhH4+ak2Ri6tQc5P16t2rT
         uvse5vDz1WrCI3KY5n+rcMxjgfy3Wsl78lIrhlUhVLtVN2LCu+mi/HUWXkhwEYaXy6O7
         UDWIDP10nfWToooTPTn9LlmZnu3UU0UcQhD6B0HVZ0GotD3EV+7zmdqfiCwSvMUdzKMP
         henw==
X-Gm-Message-State: APjAAAV/LnuEuWNKmn/RKwWkLC9e609AH/HPbDUpRgxX8xW404u/fAf/
	h/P45GKV6acldifMY8DvmxkyzfxiJeAlvlgAvv9FMn1H0szqK7dHVFDmus0pYr8KBz4v2Z0mk5z
	DuPQNZMhJ2jWHt28WuqHnHczNGpgUQxT0ClTh21K/glUOxs2rJv3lrudC3soW15JSjg==
X-Received: by 2002:a62:53:: with SMTP id 80mr10902240pfa.183.1557820683944;
        Tue, 14 May 2019 00:58:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFYhlhs6yVmWnWWHsDkCaWTsImHBII/Va6/WEpidBsqH72zcucjTvF6FglX9YuYZILEBCu
X-Received: by 2002:a62:53:: with SMTP id 80mr10902186pfa.183.1557820683141;
        Tue, 14 May 2019 00:58:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557820683; cv=none;
        d=google.com; s=arc-20160816;
        b=tRyVr8KPkYwp7R6l2Hyjkvlzu/GfXdsEGtV7SkQUKQORtQ5CfgOk9SdyyqbiuA77CX
         fXs1h+5h70VxKeI+h1ZAHYozJRjAVSSrUpMn7FwbVOK9wlAbZB6f5AZADbE9LqVPmJTc
         OFoM3CmNXVtz/w9zy/zu2qPWzFu+UA57HTsBnHoBRa05pD5sHjYfu7UJOWAmaJkKm6ll
         6igV6NFR0H7wH5xcxC62gcVpNiUWTDC+DQ1MQk+YYuwIRUel74Rg4dfD/EM67/mx9REo
         7k8mw2dk1giBkHnqhsUY3Cj0d+RgOJWnIG8Wkk3jfHKBPz2Ee/JwE4CIE7JLK4pQ3QPS
         q58g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Hm9Tm5LOAz3Yewu8iIsMrN/PygszNEAXdNiSHUZXasc=;
        b=is++uI6UdXa1cd8w+v4IowbGTXNwpDJiFX8PIq2RKV5APKanUeyeJeTfZP0DjdOjRH
         Nco5Y8PB0K8jVtySzvPNgMPqKUCd+k9ddp7TRFtyfF3pS129E11m0dRL/J1za341hoHz
         yy4hh4GbRQdWZl0rb9TBdZ8L9+pBeb9r3hP0KkTEeAwV1qr2n9boLC2rzGf7RTfZmKGE
         cTy/TtWtv9o008OoTvax1+DIe2qVzFcTgS7fVo6kCwtCGA4mbj0nhpLg0CoGmLe4he8b
         c+ofHgg8nJ9ud5+3r1wsX2UL3KlEeczdKAVEWHAU1120MfXb1A2v0IuXnEpDpkyV2f5B
         PEAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Cxu0Rbtn;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id bf1si176325plb.49.2019.05.14.00.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 00:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Cxu0Rbtn;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E7rWLj013371;
	Tue, 14 May 2019 07:57:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=Hm9Tm5LOAz3Yewu8iIsMrN/PygszNEAXdNiSHUZXasc=;
 b=Cxu0RbtnDfFw0XdHX1a2nnhh6Murm5HeXI3uwUQKENUOiWgCk+Uad2iC/dmeOx92QJ4c
 ArOiWnnJX0B4nK1vHuAdNSDrIwvsD3/DLRNjc+AfrPwlVG7eY1cpq+mQpPHLqKkSXGZM
 s3Zzb+PcTUXnnJoR0u5Vu0UtNpHoH2qD/++5S7CaEEHgYj+WZhVYhg7kpQ5gqvdiE6l6
 XxxsU8vhbvd8ChVXIr9Z9SYgOwqyAb6FiFlf+ykIotOkitY7klVomllhLJliLaJ/O8Ws
 0PBgos6GaN0Wt4URNQU2Md4SGAZ5MlFC+MM9fI6bw4HS4Mi0ylZzQx9Igug9XTnyytC3 7g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sdnttm1k1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 07:57:44 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4E7vHQ8144326;
	Tue, 14 May 2019 07:57:43 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2sdmeax9ua-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 07:57:43 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4E7vZFf007379;
	Tue, 14 May 2019 07:57:37 GMT
Received: from [10.0.5.57] (/213.57.127.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 07:57:35 +0000
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <20190514072941.GG2589@hirez.programming.kicks-ass.net>
Date: Tue, 14 May 2019 10:57:29 +0300
Cc: Andy Lutomirski <luto@kernel.org>,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
        Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F88E7218-04F2-4C86-A89E-D73695A03B0A@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
 <20190514072941.GG2589@hirez.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
X-Mailer: Apple Mail (2.3445.4.7)
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



> On 14 May 2019, at 10:29, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
>=20
> (please, wrap our emails at 78 chars)
>=20
> On Tue, May 14, 2019 at 12:08:23AM +0300, Liran Alon wrote:
>=20
>> 3) =46rom (2), we should have theoretically deduced that for every
>> #VMExit, there is a need to kick the sibling hyperthread also outside
>> of guest until the #VMExit is completed.
>=20
> That's not in fact quite true; all you have to do is send the IPI.
> Having one sibling IPI the other sibling carries enough guarantees =
that
> the receiving sibling will not execute any further guest instructions.
>=20
> That is, you don't have to wait on the VMExit to complete; you can =
just
> IPI and get on with things. Now, this is still expensive, But it is
> heaps better than doing a full sync up between siblings.
>=20

I agree.

I didn=E2=80=99t say you need to do full sync. You just need to IPI the =
sibling
hyperthreads before switching to the full kernel address space.
But you need to make sure these sibling hyperthreads don=E2=80=99t get =
back into
the guest until all hyperthreads are running with KVM isolated address =
space.

It is still very expensive if done for every #VMExit. Which as I =
explained,
can be avoided in case we use the KVM isolated address space technique.

-Liran

