Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B25C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AB852229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MZedQmTF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AB852229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9445F8E0002; Thu, 14 Feb 2019 14:41:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F6258E0001; Thu, 14 Feb 2019 14:41:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E5018E0002; Thu, 14 Feb 2019 14:41:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7BB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:41:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a72so3629377pfj.19
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:41:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=apLII46OMYo+cg86nwZC4fn9BuMmo44baMnBMROcUX4=;
        b=Zdjve6Ku/cwHvgsATlH2bj1LwvwTNVZAxE2IHKwMfJgSArTbtBKAvidNJwfDHe7OMl
         kDKH/AAGip9Y4DuTgAbv55fEDuz/FFHpKDdfVrfrau2/Z9YjyzT0/0jZK5gGsYtFD6I2
         /qPPeCDtexC8xeVYvVduER8NEnPnz4pD69BaB+QfDD2cdIDRHfrVwcvl3n8/ZzBGYti5
         u1Mg0H4itwte/SXaRfPUWTr9o8l/2IVmhRd+ajBGY9iP3IffkiPA7N/w+GPRxxDVbWjb
         T5WGeCMsU6ZibWJF1PvYWylAInPBJcDttYiaMQ6u+gXLSbwtUWN1TIGnosgI/7IWMlgm
         jiag==
X-Gm-Message-State: AHQUAuYlU5jx9LdJHmvvloMEX5Lf5cuteX7V/kp7PosxADAsRqVv70ct
	QkiGKRiGjgL/79X8XF37NBhmabq/1RNO8dD5ga5OJuRQZuLOIaqGLzhQu7VvFuJujSeS1c4KqKt
	1RCvfpdOenMQHsn8mFYLrUgWpy7WVAMQ/mzHcV+fgxnQV1HBcaUsoBCMCMwGyW5qxGg==
X-Received: by 2002:a63:c54b:: with SMTP id g11mr1509167pgd.441.1550173292876;
        Thu, 14 Feb 2019 11:41:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbnrEKoyMpnsQE3/G970rQ6IyFAoZ9FTGpkwGC+5/XL0agDhhtJZJUHH1kjRN8wYC+cp1Z8
X-Received: by 2002:a63:c54b:: with SMTP id g11mr1509124pgd.441.1550173292078;
        Thu, 14 Feb 2019 11:41:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550173292; cv=none;
        d=google.com; s=arc-20160816;
        b=u8BD1yU5wE6yV19l4AOGdVHt0PAUDKI9DsiiIUXvJ9dqjqCW5n/4v/qsqOziE2ntPE
         k/zQ4AH8trfpmDBKUCcikOpYP5mmx8A2N2buw40Booenfg+eBUp9Is6j3OhmRGFEPwVC
         IVC0ZTldt4U3rRWI4sv05e13EU6kfF5BW7krjFkYKojvtygme99o4C2Nu+mK5kCNoU82
         A1YD3NXUecKzCEQYerLSujrE9E2fFrpIA2DZdtM8ZWgmfvaI78zUDV9ArSolJ9qh4OoR
         QQ0sLBa0e9O8b4JUXAVKQ/gFVNRqabM81CG3hWAKqHuZkSuFEiYDq9o4qzBDmhuqkBuc
         C6Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=apLII46OMYo+cg86nwZC4fn9BuMmo44baMnBMROcUX4=;
        b=xuT7kpgm3R2o6jny7c7diwX6CylptfqMavhmiU+38mGi2pPUiqoHWiRPHJT5ku41HW
         r8qo2cyEIYRd3i650yN6+8yh4q/Dph5nJtYRy+LmOMmvqU/kIqqkpF7Ozp7uhZfPIkAv
         8OdML+hOYQTz6l/LHDi2L5PDmI9/EtGn9qnPZXbJm43gkaCLFqZbXevZ66RMSTQS5/2D
         kcO0zY3O3+mxTDslCGy5LphsaTCw5i0Mi70suHMuYQOTwYn1ne/DC7r0q+SsJr/s6yNa
         UAYXUD3AwLe7C5aGlpVVdkyiCHo+TRE87SMqyP/2AaSgL8k6G4iWZY4dSHGBvfZ3sMpt
         y3OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MZedQmTF;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 44si3480526plc.110.2019.02.14.11.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:41:32 -0800 (PST)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MZedQmTF;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EJdUbm061971;
	Thu, 14 Feb 2019 19:41:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=apLII46OMYo+cg86nwZC4fn9BuMmo44baMnBMROcUX4=;
 b=MZedQmTFw8lqAGf7lkSowq4Oe5jibcC+tqVRqe4BL+nILuU1iRFr096bz1mNeucrIT6f
 XkAGy7R5+L5ry3TBCMFcstdGs0Wboj+WphAs6T1bICLon5Gczh6joG7MTbSBnvYKUY6T
 05x/Cy3c7wSxDtr1v9FRGPODrL6IMekG+hZliIlMVat+CiPb8SNq6oHXdk+yMXK2geSc
 oo2yeqivfirc2dVzKVNaM7ByMhsWG4tz0u3wB+bLIP+kqgDWLDtWCOru/sD7RBiF0mCC
 TBlhM593ZenV5upbdGevAsZZeQbNuodZrZ+PUYu9sHfYO9w1qq4/1Q/sOVVvif0QJEmI rg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qhre5t17e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:41:23 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EJfN1b022518
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:41:23 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EJfMYP009048;
	Thu, 14 Feb 2019 19:41:22 GMT
Received: from dhcp-burlington7-2nd-B-east-10-152-55-162.usdhcp.oraclecorp.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 19:41:22 +0000
Subject: Re: [PATCH v3 2/2] x86/xen: dont add memory above max allowed
 allocation
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        xen-devel@lists.xenproject.org, x86@kernel.org, linux-mm@kvack.org
Cc: sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de
References: <20190214104240.24428-1-jgross@suse.com>
 <20190214104240.24428-3-jgross@suse.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <222f5551-0d1f-b0d9-a044-7849f909a802@oracle.com>
Date: Thu, 14 Feb 2019 14:41:17 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214104240.24428-3-jgross@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 5:42 AM, Juergen Gross wrote:
> Don't allow memory to be added above the allowed maximum allocation
> limit set by Xen.
>
> Trying to do so would result in cases like the following:
>
> [  584.559652] ------------[ cut here ]------------
> [  584.564897] WARNING: CPU: 2 PID: 1 at ../arch/x86/xen/multicalls.c:129 xen_alloc_pte+0x1c7/0x390()
> [  584.575151] Modules linked in:
> [  584.578643] Supported: Yes
> [  584.581750] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.4.120-92.70-default #1
> [  584.590000] Hardware name: Cisco Systems Inc UCSC-C460-M4/UCSC-C460-M4, BIOS C460M4.4.0.1b.0.0629181419 06/29/2018
> [  584.601862]  0000000000000000 ffffffff813175a0 0000000000000000 ffffffff8184777c
> [  584.610200]  ffffffff8107f4e1 ffff880487eb7000 ffff8801862b79c0 ffff88048608d290
> [  584.618537]  0000000000487eb7 ffffea0000000201 ffffffff81009de7 ffffffff81068561
> [  584.626876] Call Trace:
> [  584.629699]  [<ffffffff81019ad9>] dump_trace+0x59/0x340
> [  584.635645]  [<ffffffff81019eaa>] show_stack_log_lvl+0xea/0x170
> [  584.642391]  [<ffffffff8101ac51>] show_stack+0x21/0x40
> [  584.648238]  [<ffffffff813175a0>] dump_stack+0x5c/0x7c
> [  584.654085]  [<ffffffff8107f4e1>] warn_slowpath_common+0x81/0xb0
> [  584.660932]  [<ffffffff81009de7>] xen_alloc_pte+0x1c7/0x390
> [  584.667289]  [<ffffffff810647f0>] pmd_populate_kernel.constprop.6+0x40/0x80
> [  584.675241]  [<ffffffff815ecfe8>] phys_pmd_init+0x210/0x255
> [  584.681587]  [<ffffffff815ed207>] phys_pud_init+0x1da/0x247
> [  584.687931]  [<ffffffff815edb3b>] kernel_physical_mapping_init+0xf5/0x1d4
> [  584.695682]  [<ffffffff815e9bdd>] init_memory_mapping+0x18d/0x380
> [  584.702631]  [<ffffffff81064699>] arch_add_memory+0x59/0xf0
>
> Signed-off-by: Juergen Gross <jgross@suse.com>

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


