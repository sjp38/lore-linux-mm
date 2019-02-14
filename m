Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4F7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B199D20842
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:59:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="dz2KSoaS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B199D20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58D4C8E0002; Thu, 14 Feb 2019 14:59:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53CD28E0001; Thu, 14 Feb 2019 14:59:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 452A88E0002; Thu, 14 Feb 2019 14:59:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 078228E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:59:17 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so5029592pgu.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:59:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UodKr1fXU4B03KwJD9SdR+UIiFpP5cWdJfx+zOBFFho=;
        b=iIhNl3AxrOEm88gfwheEKeBtPa8aCyMrv+75VBtFfTDMqQVIJHu8uZcppXcCh0Q/ov
         3AT2bXvo3ycJMEFod1PMMsw8F6FpXTEvX6sXAwGzol/HuTz65YpiHkYFQOF5SbAr2PHu
         f3fvMZde+eMZ0rJfQTB/NbuLZTTOy8NnPaUXBF1H9zPudreg8gvJvhMR16yw6cd21EVJ
         /9/MZVy33CHfbdTYh1m7ecot5ZqZ94fmDsZqgG0+haNwhT3SncyW9JncoIj8y8NLFkKe
         3dzODnGtXpsvsMBo3LsCWlicB84AWiXZ19biwgVBerqCT5IVSAcSzHwTcm7hbXyKltU+
         1M9A==
X-Gm-Message-State: AHQUAuYMJz4uBTIGTPdTUS0eQG6W1KBk5hWmc+zQWdg8z9IWgchEEfID
	xW6vsUb5i01mh20mYlLXRXzgzV7N7vnFoS3SQAufxTepTm1ZJ8G0jmh+CJ+ANhU/3O6aTTUy9mX
	KmdW/NkSdiz6hTlUS9MjO8oFyk+hPvy5LABHBdtJNhOiinI5hIA7x6WeBMX7q/EoiEg==
X-Received: by 2002:a65:620a:: with SMTP id d10mr1540673pgv.75.1550174356691;
        Thu, 14 Feb 2019 11:59:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjupN3YCMBlk5Iq/COfAS+ZqGoxyBmCgqoJs5tQfng2x++UAfgzWfGwJvevo+thC9KsuIc
X-Received: by 2002:a65:620a:: with SMTP id d10mr1540622pgv.75.1550174355943;
        Thu, 14 Feb 2019 11:59:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550174355; cv=none;
        d=google.com; s=arc-20160816;
        b=sqQHqB7pWTUZnchCqMWCyAWBdexiNbj3XZn4XWLI9za9ro1QYbzVnX7QEY2LGqWQGD
         n2ATtS6o+EiBsmIZdb7wygLMh4R0IPAZlFYD2cj4nuJGi4M1dx7DROhDzr8bab2QjdIT
         hTWjwlPPhldtYrNjF0MgJpEvu9pbQTfD5OlZPOlmJw1X2zz4oQP/J1Mt+PCrMvEv77wZ
         4xG5rOxqApVY6BJSVeBfDC8fezyXsvlZuBNUHwezP/IvuXstbFafBL9wl42mMUgIHhP1
         qdai4WHN7OTYaUv8aiaPQVZ3oeODUJvwHaas1tXzN9K3MLAX6MvhnHkoNDVIBnSxVla8
         23mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=UodKr1fXU4B03KwJD9SdR+UIiFpP5cWdJfx+zOBFFho=;
        b=u4+P4i61MoI2iVgi9GQF/BpxHYMKRilMiI1bx6qbq6RFzUrGMYDYPxYl/yjUso3tpy
         NamgL110yCwmNSQ7526nriKr6szJeELF/NOqBX3b0B01/5NEpAKcJjQJ75r4V1VA9Tt0
         6XaiBBgBXaBXTMP0bLpa6vNcd/jCmnMhFdOHO/J5t1Jspk6LFnwk5Oz4iRUwRAFTcCmE
         +1FkKmC12D1dkgHBlI4aSeuvwSzHjbm2FUsjbsjlU44/LDI/roJ6w7TwZsvg5IADRFUA
         OH5KSEyo9DIQwAcrO20Zy2Yz/aTxBOdYMomN3PUFnbf+skObETTW3mdQAgXJytzI0k3K
         gkJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dz2KSoaS;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d19si3345454plr.327.2019.02.14.11.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:59:15 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=dz2KSoaS;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EJrseS067506;
	Thu, 14 Feb 2019 19:58:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=UodKr1fXU4B03KwJD9SdR+UIiFpP5cWdJfx+zOBFFho=;
 b=dz2KSoaSHx5EwTIfMkUMYh75KBTt6+5VYapY90JnPP3YN45gOftu/wFTxrsPeGsbmK5h
 +visaHIEiAvue4Xd+4bGNgYt7lbfc+zYfOXEQzRMHKJUFxnV1tG6g65+q5tfG6aA3BpA
 D8TtR155ODag8FBNXzn3S6DTZiyWB6F0pJdzRGEzuSmzl9Rz9LQqmIfzNKYzbRnN9bc/
 lBRUIM6Y5Oq6+T6oN6RGvDzO6uL4zNKXvnmZ+PsB2H2eDIOrR+gKGarWeP2ch5DMY2ik
 Od+aJaE2jMhXzYO/HAqzB74XTf11f9opBt+Bj0bQDOut39OrK+J4N+QoAE3ahIa8FFHa fg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qhrekt4hs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:58:57 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EJwus2011554
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:58:56 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EJwuSJ018915;
	Thu, 14 Feb 2019 19:58:56 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 19:58:56 +0000
Subject: Re: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page
 Frame Ownership (XPFO)
To: Peter Zijlstra <peterz@infradead.org>
Cc: juergh@gmail.com, jsteckli@amazon.de, tycho@tycho.ws, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Marco Benatto <marco.antonio.780@gmail.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
 <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
 <e157e274-1bdf-0987-bfe9-21c9301578ab@oracle.com>
 <20190214190803.GQ32477@hirez.programming.kicks-ass.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <3b55fb25-9571-2208-4e04-052cd6dd4fee@oracle.com>
Date: Thu, 14 Feb 2019 12:58:53 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214190803.GQ32477@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 12:08 PM, Peter Zijlstra wrote:
> On Thu, Feb 14, 2019 at 10:13:54AM -0700, Khalid Aziz wrote:
>=20
>> Patch 11 ("xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION") clea=
ns
>> all this up. If the original authors of these two patches, Juerg
>> Haefliger and Julian Stecklina, are ok with it, I would like to combin=
e
>> the two patches in one.
>=20
> Don't preserve broken patches because of different authorship or
> whatever.
>=20
> If you care you can say things like:
>=20
>  Based-on-code-from:
>  Co-developed-by:
>  Originally-from:
>=20
> or whatever other things there are. But individual patches should be
> correct and complete.
>=20

That sounds reasonable. I will merge these two patches in the next versio=
n.

Thanks,
Khalid

