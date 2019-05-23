Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E55C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A7B72184B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:52:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vDS9uTH4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A7B72184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4C7B6B0291; Thu, 23 May 2019 13:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D238D6B0294; Thu, 23 May 2019 13:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C116E6B0295; Thu, 23 May 2019 13:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4326B0291
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:52:07 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id w139so2217374ywd.13
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2Qeh79aDTooqgUiqrhLo6Vy7tycJTudTXGs6zz5dfRs=;
        b=V9XYXzzpPLjwB01u7aZgCGDCzxtHP6zIGgJjQWLvmSvgq5pfwGyh7ZE+L11hBI1Ev4
         BXWTBpHQBe6OFWR431Q051hRIN7d2Af4AG3NMp47+AwkUKFcOidlmnpA+Q79v4g6mdNc
         +GGPjeSo2rBmHDU0USrzhp9mu80otUPITVo5w41ssataoUxtAtWg8aZZ26g6C0xXi2TS
         EfymhRXZgSIX9C491zlLbNl0NPg2taNWd2dW+uWvDCi1wvyWlIynsDpIi3zZ43nRUVwo
         MVLGKIq6MEsiCZ4Ya7gOfw8B8FJnshbbe6OKpZdVbg6FCcHr8Mj+rF/F99bxo9pfVYNF
         2IxA==
X-Gm-Message-State: APjAAAWtdD4f9F+oFu4calYqHuPasRk14F/NYAV/SJGiSVECL5BVmilr
	j6skWtTUboO7cQj8ZEBnlbO6MImm5ivzEeKM3xNPe7NKaHL4K3/fjr42nk7i1sUFHzSffIemuWF
	KERBIeVMXWAu/w9vHNOSdUEu1vJ6y+YeAfZ13HIqsozQ8IsmA4KviQmHKuz0YHM0FWw==
X-Received: by 2002:a25:db93:: with SMTP id g141mr9768176ybf.230.1558633927347;
        Thu, 23 May 2019 10:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwJ409jZGK4uau2kbAtSLO7fKr1TYI0UifxzzuyHqxp13EqraypKdXcLTBIRHvW0bVQQ0i
X-Received: by 2002:a25:db93:: with SMTP id g141mr9768154ybf.230.1558633926756;
        Thu, 23 May 2019 10:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558633926; cv=none;
        d=google.com; s=arc-20160816;
        b=hAFQEPNuejTc5R2xhXYx49QhOkn2eoiPYw8Z7trYE7s0uYc+45NHGVVzHnpFPwF77h
         Jne7x5mhEsmz31u0JD/2ByURIBnvlWkegLCGNINl9tpaELoub7gxGjj2KDDn8+SMS7yb
         jtVNHngHpIWuojLqn/dWTgtxa1KWE8D/0V8w9KfEnhRQblE7o21lM/iW5+mEe2x9sVVw
         FrK1ib0U2RiZQ+REPyDXu7PG2ny/0xE2+hjJyNPrv6pZzmXybz76VCUnVfO/6sj7RzXv
         o604kKnx0F0e1+cI3V+X3V0CgTRHf/qi/v7XNjQXQLnE6F14YyXA7uri6R8xCU1aD8Ud
         gJbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=2Qeh79aDTooqgUiqrhLo6Vy7tycJTudTXGs6zz5dfRs=;
        b=BjQyjrPQ5eHy08zeDa6wdNJV1diJKh+P1Arfu+KpU+TpIZF4NwlD2uS9AvLUgosQRB
         X58BM0kYNHT+k5dLXMn+n+fMXTgB3E0ic/K4Njp0UGGUXLD4QYZopWhd2WGGqNXqyw8H
         2JIb/ca1gAm74W8xBYGlun8+iC+wwIYtpZT21uV1Tz86gbiFOeNPXzfThyrewAPmQ2xA
         BlNtWYvLfxeIrIrinBud3mo6cKEbpFWe1pezPFky5gKKjf0EgZK46ZlT7tYkHUz9PuiP
         TokUPP1dAK3L/QkJDqQtuNt6gmGW7+VpBLl7TLVe+9OIpvYT4NqA59E6V72pL2/hTLuM
         BiZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vDS9uTH4;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a13si1486773ybl.184.2019.05.23.10.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 10:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vDS9uTH4;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NHcV4s194594;
	Thu, 23 May 2019 17:51:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=2Qeh79aDTooqgUiqrhLo6Vy7tycJTudTXGs6zz5dfRs=;
 b=vDS9uTH4+Zc8nPFLnuUvRu142pBiqAxGE5BbMuCn+MA1cOmcParAIWPYB10Gy4C7hxOT
 CRf7KLq6LlEZK+PTvChfiuPo3LEMa9ckzl+/kAdOakkMJYpGPlnCYhLx+3+n6Ntz8J6i
 3fNosLO+WWxHrhBnbE6IQD52DA+Q7+ZHzBvkxtJ6IhCd+FH3wqHlFGg3maBxYupT10pT
 epJuSNSnm8akAZ06VD98fPXl3vSfL7K8WT0tE28XcUzOExtBXHl5878ViO1cXVVBk4Tq
 4+ZzcfJ8p6oqlalneN0hlMs1txpq4s5U0HxUj4eJGEhRr1s4PIHpmSUBA5IcjIQCgxcH gg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2smsk5c473-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 17:51:53 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NHpCpe145061;
	Thu, 23 May 2019 17:51:52 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2smshfd4y8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 17:51:52 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4NHphUB003086;
	Thu, 23 May 2019 17:51:44 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 23 May 2019 17:51:43 +0000
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Kees Cook <keescook@chromium.org>,
        Catalin Marinas <catalin.marinas@arm.com>
Cc: Evgenii Stepanov <eugenis@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling
 <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
Date: Thu, 23 May 2019 11:51:40 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <201905211633.6C0BF0C2@keescook>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9265 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905230119
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9265 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905230119
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/21/19 6:04 PM, Kees Cook wrote:
> As an aside: I think Sparc ADI support in Linux actually side-stepped
> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel must=

> be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI
> for kernel code.") I think this was a mistake we should not repeat for
> arm64 (we do seem to be at least in agreement about this, I think).
>=20
> [1] https://lore.kernel.org/patchwork/patch/654481/


That is a very early version of the sparc ADI patch. Support for tagged
addresses in syscalls was added in later versions and is in the patch
that is in the kernel.

That part "Kernel does not enable ADI for kernel code." is correct. It
is a possible enhancement for future.

--
Khalid

