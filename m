Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 882C3C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 10:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F8C20881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 10:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="eZGNKozF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F8C20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5956B0003; Tue, 14 May 2019 06:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C96116B0007; Tue, 14 May 2019 06:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B85106B0008; Tue, 14 May 2019 06:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEC36B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 06:27:11 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n4so11248952pgm.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 03:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HyoEJG6NjsyHsNKNQwL239w7XdNZ36sL7RhVidoBH+Y=;
        b=dFtfDm58jS6U3ZPz1nzyeT0UdpO4gjx0EDyXMUQ7LSkLKlKznO9Hku+B3G9zZPxfCf
         HhvY81HxWFf4FixlI6Ny3/j6T1QFD5p8vKeyfuQpCMQVP5OvBwkWLTEo+fUl4atGGCHZ
         7tFbPT9V0dyIV31JXNt4wL+Xt0kIsRGlOw1OeKCHrhljJZcH/E00WfN4MZ7zs4r2R770
         7C6tt+jGDQ3wLpcfB3rbdQgyyKUgHM6uaJTYGh09Y9PSFbeF8/+x2T+MGtYHcndwjEKb
         khSGkT041alC5Z/853fhRw45XloickBjapotS7F9I13BulNxUFjGD7Tan4wpak5YcW4T
         nnzw==
X-Gm-Message-State: APjAAAV2E0VuZ/uA7FBBNfB2hGUkR6S/xZbFO9uDB2tqz5N82cvcd1I4
	n8Dx1A1Sk9c6afXmHroL05PU0KN1dP5GC3sdzX1ar0pANA0l6IAb3NolBAhxXGw0QsFS14lnv11
	07Rma3tR+I3tLUzttZ13TF0ck0uMmWfL1VpnOpiuPRGBPE3DpOmus9i0RwxSjgmzL9w==
X-Received: by 2002:a62:128a:: with SMTP id 10mr38994995pfs.225.1557829631012;
        Tue, 14 May 2019 03:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfopm4NOqFMjZL4k6luu6aCP6VAixAseIpv8jmnXqF9WNdUg2HtpzijevTOVJoBdbxCCfe
X-Received: by 2002:a62:128a:: with SMTP id 10mr38994894pfs.225.1557829629788;
        Tue, 14 May 2019 03:27:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557829629; cv=none;
        d=google.com; s=arc-20160816;
        b=wR+AXAzkOoFjesJ33+FQXUQ44kEJDWyA5KZTPdUWwOnCQyLaoIvZAWUsLFcGtkSEGB
         cht1vQVfsfWqJLlZ4MbwqmaK+utWFLGcPjToYDitBc6HDxcyqndi531Cht1aJOMA+ovo
         MpPR/Kawe1ciIjXvy7z0Ko5LIy6Fe7JUGYjjU4muBVN0OZByD/rNqBohvhp5mwfvX0SS
         AK5nXt0/Dde/7gvnGOSKVEUixe6pAxrXOJGLLP3BK+TnrpcvadPlUpKSzQDQwfGpjEig
         dorcUZ+Q82P3dsEJOeqXREB3+vEIOiwpLggtDeFtU/R6C0y9TytPwTwsAwwL696LNcGy
         gIFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:references:cc:to:from
         :subject:dkim-signature;
        bh=HyoEJG6NjsyHsNKNQwL239w7XdNZ36sL7RhVidoBH+Y=;
        b=oo6h9kFDErdf4/gO3GMtgA6FcLPrmCVPgeDpzyyXjIrNdLTm9pnzWnJHnzoOapXSjI
         CUsLmTEN2imBWfj6UbTITjheVO2qrQdN9dr4Y+43vlUdEr4rHx34Y8z4+UU2kC/ExsLN
         1nsMDg6NsktRnk+viP7t7fL8Ah7DNETyKzaDPruZhVI/qZvdNo7WQfx11DIBcgpzaQ2B
         L2FDNuwJJZyr+88M3+wryc2lIkdYNVgEVoO0d/jooZP6IewMNV8rqTCd88e+8Q2imKAt
         Dax3EKIvgtgBTQ0xz4ioMthuJl3btAIP2Eyp17IKFAexri/hkTZHxLY5QktkzWKlhOn+
         /6oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eZGNKozF;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y16si380903plr.150.2019.05.14.03.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 03:27:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eZGNKozF;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EAOCF4162648;
	Tue, 14 May 2019 10:26:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=HyoEJG6NjsyHsNKNQwL239w7XdNZ36sL7RhVidoBH+Y=;
 b=eZGNKozFDNYKTFY2RTWJ35YGfn3mhjEA8HHUXglMJawyb8sst0F7BP0/4Tqo8wyOl/Zl
 c984f8fM9ND92GrFfsqMa0Ekw3FYrxj9nyaI6XB/ijWegKO7CEuHzv/bEDXWjbKVyHtB
 aP6vteMS5DEMIeUb1zbdHhC1a9NWZOEQWAd2ZsDebp00Li4T5WyeXFvyS8a6FIj9uYBg
 IyFKQeacv8bVjNGoYSzwd6LMyAHhggvTMnVuBy7xcd1xGRc3WmKn8UoQFkKIG7NF+vmK
 NwQN3wj7rJzV9JSEieX+QQ5xD2mZUQoMxeQ4Xcn23Lp/CvNFBG6uQZpIc8/pqjiWzQb0 YQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2sdq1qcubw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 10:26:50 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EAPYwj130365;
	Tue, 14 May 2019 10:26:50 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2se0tw2na5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 10:26:50 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4EAQlqh024795;
	Tue, 14 May 2019 10:26:47 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 03:26:47 -0700
Subject: Re: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table with
 core mappings
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
 <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
 <463b86c8-e9a0-fc13-efa4-31df3aea8e54@oracle.com>
Organization: Oracle Corporation
Message-ID: <daace7ff-e85c-442d-a53e-6e08c5fb8385@oracle.com>
Date: Tue, 14 May 2019 12:26:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <463b86c8-e9a0-fc13-efa4-31df3aea8e54@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140076
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/13/19 6:47 PM, Alexandre Chartre wrote:
> 
> 
> On 5/13/19 5:50 PM, Dave Hansen wrote:
>>> +    /*
>>> +     * Copy the mapping for all the kernel text. We copy at the PMD
>>> +     * level since the PUD is shared with the module mapping space.
>>> +     */
>>> +    rv = kvm_copy_mapping((void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE,
>>> +         PGT_LEVEL_PMD);
>>> +    if (rv)
>>> +        goto out_uninit_page_table;
>>
>> Could you double-check this?  We (I) have had some repeated confusion
>> with the PTI code and kernel text vs. kernel data vs. __init.
>> KERNEL_IMAGE_SIZE looks to be 512MB which is quite a bit bigger than
>> kernel text.
> 
> I probably have the same confusion :-) but I will try to check again.
> 
> 

mm.txt says that kernel text is 512MB, and that's probably why I used
KERNEL_IMAGE_SIZE.

https://www.kernel.org/doc/Documentation/x86/x86_64/mm.txt

========================================================================================================================
     Start addr    |   Offset   |     End addr     |  Size   | VM area description
========================================================================================================================
  [...]
  ffffffff80000000 |   -2    GB | ffffffff9fffffff |  512 MB | kernel text mapping, mapped to physical address 0
  [...]


However, vmlinux.lds.S does:

. = ASSERT((_end - _text <= KERNEL_IMAGE_SIZE),
            "kernel image bigger than KERNEL_IMAGE_SIZE");

So this covers everything between _text and _end, which includes text, data,
init and other stuff

The end of the text section is tagged with _etext. So the text section is
effectively (_etext - _text). This matches with what efi_setup_page_tables()
used to copy kernel text:

int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
{
	[...]
         npages = (_etext - _text) >> PAGE_SHIFT;
         text = __pa(_text);
         pfn = text >> PAGE_SHIFT;

         pf = _PAGE_RW | _PAGE_ENC;
         if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, pf)) {
                 pr_err("Failed to map kernel text 1:1\n");
                 return 1;
         }
	[...]
}


alex.

