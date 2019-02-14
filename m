Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD1BEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D610222DB
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Vf/BYccQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D610222DB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCA58E0005; Thu, 14 Feb 2019 12:14:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2830D8E0001; Thu, 14 Feb 2019 12:14:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 126368E0005; Thu, 14 Feb 2019 12:14:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C14518E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:14:44 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so5259633pfj.14
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:14:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=GPxjRJQ4nY/8hYRHeyx7OooRpexTZeYSMFLDEjWGis0=;
        b=TwsiDzwTTKXcpqtDJTStiGSXOOTcJUoesIf7zwDfMXxMQRU3FCrA+lppi89eRVlkAl
         y6mWmF+dXU+Xf3NJhbNG1Fu43gsobHHj4BbegANxaqHcuRDU4KGF4xFkLOzg1o0SFMBI
         p0aR/If3y24hOu2yUceGQPfFEIJn7W1N973SgWIo1FoEpEhaTYPSlmtjHQHoBgzgJ2QB
         AqdtpWJIbrwyqsiLKkT06ZH3gRd6uo0iEwssCtRH4sRlq6uyz2rZ+K5vZj8/nmCDXoJK
         6DYvhP28Am4HHBHyXuL0dDcstuc55lsXkyz/2Nkdpu68mHCBJTBLRw2b0U64SWT8ngkv
         fRiA==
X-Gm-Message-State: AHQUAuYyM0Tk5SJUhV5tConAT1VtpFl0k5cpTTHghKgRiAQ8cPSFOofP
	ME/2CK4H5HrErcUt+C4v9Cq9j5OLybtwXnxf016zb+2oFX6Y2ld10YLxEg1ftuCfR4Eox/j7Jwe
	HW61E4T7fYTAXRnesHYkILpWR3QyDxEdD4a6Tr5njyzyQhexwjkmnU+4Op5RimSGUnw==
X-Received: by 2002:a62:5301:: with SMTP id h1mr5060331pfb.17.1550164484397;
        Thu, 14 Feb 2019 09:14:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaliqlZ515RuTjbO78FEpyUJMOIXC4PKnwprJLmLiW1o6GILhzQPFyJ8gAxu7BYG1ps6/cv
X-Received: by 2002:a62:5301:: with SMTP id h1mr5060281pfb.17.1550164483755;
        Thu, 14 Feb 2019 09:14:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164483; cv=none;
        d=google.com; s=arc-20160816;
        b=eRomHQWxXcW5VGAb+kWSwcGoxm68RT2dWkp5PGEuT3s9TmIJrNiIyDcbZyhpQGAGDS
         9cvjTXaDR/EJeSeb1jerDKffWr5Kt/BS9yD+FeSVJg1qgR+9BpX9wGJ/urix4bQKqDIs
         uYiXsDRNfad9McOdxO7KBBhhwrw0ALrk3yOaEmTuXpL3W+Kxeuo9REM6xD5JKPnZaboz
         6F9O/GUsSvjETnblXoP0ufJDkoYSeDJKQNO8CRkHJBvEOFDd3E/x3v0+lW2YqKVuZnEo
         4I7tRxEs5ftKER7900xPTxoGo1tVWF/mi6XC7Ky0l8RQ8juTkuJBcryhtsLzSN6b4DG5
         uT+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=GPxjRJQ4nY/8hYRHeyx7OooRpexTZeYSMFLDEjWGis0=;
        b=HAyKpsdHt4s/yC/oEIsz8Fb0e7RbnkPnqBZKshr15b3vOjOGLOkVcX8u66fhwVbqXf
         QdiBxCQaSw3GZw4CZdG6j0gLWuSeR9oBYMUNP5Afregd5XBc+5m566NL1c7V3t/Vjxx+
         LB1bfEN/mdZzWmy3qvKaUMZcflCUZAGLMF3sZ2uZ7Gs0/8gr78JMfdKsClDKL1Auw4Iq
         UyPwIECqm/wJR2RlBYamhgOcKI8O/Od2grzLOj+grkU3zyJHTsrsgaRZdGoChtcw3VuU
         wVOhxjumvwNIOdwi8ENGDAM3DBiT0c7t1OHJA3NLBfuH2Llh1HLpzRK1h71y+0LE70kf
         WBeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Vf/BYccQ";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 145si2848016pga.396.2019.02.14.09.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:14:43 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Vf/BYccQ";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EH8iu1128927;
	Thu, 14 Feb 2019 17:14:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=GPxjRJQ4nY/8hYRHeyx7OooRpexTZeYSMFLDEjWGis0=;
 b=Vf/BYccQKk09j22ZvF46tD522PEycqZx1/ExzdyhvsoyMIJPJZJUEByFrYlJo83d1lV4
 EujEJr6xCdFsaO58BJZRAPMKUGypUHTM9tCrYgdCwLd19rac7dyWNdd0H5ZLzE6dpP4o
 ALn+jD2GZLgOwZKuw5nQ+75FUfn1F4TuCzuwH7Idm6kjVX2dW2fM7hB/SZzZyTwn0pvl
 I5lOt32nWZumsTN8aX4EQJ6XKjFb4sbON0Q+JbcU6VK03vhIC2uEAac42rSW5ErRLNVo
 r0F/wvXic7CrpWALH2CdJRKbzSi4jxUzO+zZHdEh173g2tRa7Jp3yApXtT9IvktKeKQE LA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre5sa0a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:14:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EHE1li015167
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:14:01 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1EHDwUM009120;
	Thu, 14 Feb 2019 17:13:59 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 09:13:58 -0800
Subject: Re: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page
 Frame Ownership (XPFO)
To: Peter Zijlstra <peterz@infradead.org>, juergh@gmail.com,
        jsteckli@amazon.de
Cc: tycho@tycho.ws, ak@linux.intel.com, torvalds@linux-foundation.org,
        liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
        mhocko@suse.com, catalin.marinas@arm.com, will.deacon@arm.com,
        jmorris@namei.org, konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, Tycho Andersen <tycho@docker.com>,
        Marco Benatto <marco.antonio.780@gmail.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
 <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <e157e274-1bdf-0987-bfe9-21c9301578ab@oracle.com>
Date: Thu, 14 Feb 2019 10:13:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
Content-Type: multipart/mixed;
 boundary="------------5EB9E0AEF4F8AD7EE9E16E15"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------5EB9E0AEF4F8AD7EE9E16E15
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 2/14/19 3:56 AM, Peter Zijlstra wrote:
> On Wed, Feb 13, 2019 at 05:01:26PM -0700, Khalid Aziz wrote:
>>  static inline void *kmap_atomic(struct page *page)
>>  {
>> +	void *kaddr;
>> +
>>  	preempt_disable();
>>  	pagefault_disable();
>> +	kaddr =3D page_address(page);
>> +	xpfo_kmap(kaddr, page);
>> +	return kaddr;
>>  }
>>  #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
>> =20
>>  static inline void __kunmap_atomic(void *addr)
>>  {
>> +	xpfo_kunmap(addr, virt_to_page(addr));
>>  	pagefault_enable();
>>  	preempt_enable();
>>  }
>=20
> How is that supposed to work; IIRC kmap_atomic was supposed to be
> IRQ-safe.
>=20

Ah, the spin_lock in in xpfo_kmap() can be problematic in interrupt
context. I will see if I can fix that.

Juerg, you wrote the original code and understand what you were trying
to do here. If you have ideas on how to tackle this, I would very much
appreciate it.

>> +/* Per-page XPFO house-keeping data */
>> +struct xpfo {
>> +	unsigned long flags;	/* Page state */
>> +	bool inited;		/* Map counter and lock initialized */
>=20
> What's sizeof(_Bool) ? Why can't you use a bit in that flags word?
>=20
>> +	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
>> +	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
>> +};
>=20
> Without that bool, the structure would be 16 bytes on 64bit, which seem=
s
> like a good number.
>=20

Patch 11 ("xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION") cleans
all this up. If the original authors of these two patches, Juerg
Haefliger and Julian Stecklina, are ok with it, I would like to combine
the two patches in one.

>> +void xpfo_kmap(void *kaddr, struct page *page)
>> +{
>> +	struct xpfo *xpfo;
>> +
>> +	if (!static_branch_unlikely(&xpfo_inited))
>> +		return;
>> +
>> +	xpfo =3D lookup_xpfo(page);
>> +
>> +	/*
>> +	 * The page was allocated before page_ext was initialized (which mea=
ns
>> +	 * it's a kernel page) or it's allocated to the kernel, so nothing t=
o
>> +	 * do.
>> +	 */
>> +	if (!xpfo || unlikely(!xpfo->inited) ||
>> +	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
>> +		return;
>> +
>> +	spin_lock(&xpfo->maplock);
>> +
>> +	/*
>> +	 * The page was previously allocated to user space, so map it back
>> +	 * into the kernel. No TLB flush required.
>> +	 */
>> +	if ((atomic_inc_return(&xpfo->mapcount) =3D=3D 1) &&
>> +	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
>> +		set_kpte(kaddr, page, PAGE_KERNEL);
>> +
>> +	spin_unlock(&xpfo->maplock);
>> +}
>> +EXPORT_SYMBOL(xpfo_kmap);
>> +
>> +void xpfo_kunmap(void *kaddr, struct page *page)
>> +{
>> +	struct xpfo *xpfo;
>> +
>> +	if (!static_branch_unlikely(&xpfo_inited))
>> +		return;
>> +
>> +	xpfo =3D lookup_xpfo(page);
>> +
>> +	/*
>> +	 * The page was allocated before page_ext was initialized (which mea=
ns
>> +	 * it's a kernel page) or it's allocated to the kernel, so nothing t=
o
>> +	 * do.
>> +	 */
>> +	if (!xpfo || unlikely(!xpfo->inited) ||
>> +	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
>> +		return;
>> +
>> +	spin_lock(&xpfo->maplock);
>> +
>> +	/*
>> +	 * The page is to be allocated back to user space, so unmap it from =
the
>> +	 * kernel, flush the TLB and tag it as a user page.
>> +	 */
>> +	if (atomic_dec_return(&xpfo->mapcount) =3D=3D 0) {
>> +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
>> +		     "xpfo: unmapping already unmapped page\n");
>> +		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
>> +		set_kpte(kaddr, page, __pgprot(0));
>> +		xpfo_flush_kernel_tlb(page, 0);
>> +	}
>> +
>> +	spin_unlock(&xpfo->maplock);
>> +}
>> +EXPORT_SYMBOL(xpfo_kunmap);
>=20
> And these here things are most definitely not IRQ-safe.
>=20

Got it. I will work on this.

Thanks,
Khalid


--------------5EB9E0AEF4F8AD7EE9E16E15
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------5EB9E0AEF4F8AD7EE9E16E15--

