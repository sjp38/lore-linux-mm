Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 853E3C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A90720855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RkpJHFBw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A90720855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7014B6B000D; Thu,  4 Apr 2019 11:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B1696B000E; Thu,  4 Apr 2019 11:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 552EC6B0010; Thu,  4 Apr 2019 11:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35B216B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:17:06 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q203so2472093itb.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MR9XSpEeqL8KNMIKhJwqaUWQnfjgzJVyCNhDLZ5BgCk=;
        b=bdIns7+HwOvz1q0x28v9oeSoL5SWNu+6H0tjrZP85Vfl1Jk9FxgGWRsNugc11Sa2qd
         +OVLwl2UxOS0urOIspUcR+J/gPfvaJxYUzg5looTSPb+ta8gfvyBpy7fC7NPEBXDB+zw
         Y+gXYy2DIZwL7XdyIp68i/a0fYtLAkhMgNr1yy5FvMZhAmN1KiVqP3OLsyfdH/9Rpe4H
         90xrwcLfGc5lcW1vi8nKGck9Unywls0jXUZPlpn5/hHvblghg4M/ZiMAEe8XonLY3MxR
         T50x6qbMzlPfSZKDGCNvVVtBNFYteStMNNtMZiHC/xGuSdWrKtc/Rba93d2lsKin3E34
         YF0w==
X-Gm-Message-State: APjAAAWTuyj1jFZvXKLWL3bht8ZmRXQZD+M8dOiAfP2rxmXDVyrjdV/x
	KUOLJvQcZwMm5zr940GfUnNrtp8Ar9LLOBeo+BG1pgA5GkCTeQ4AUY10Bm4KPgGGsxFDRUo8V20
	4poUvGLftGJ+vW1qTxHK3wgIH70pUdFQztZZVp7nHO7DawrjEZqbwBaJjvzrD0raOsw==
X-Received: by 2002:a24:4511:: with SMTP id y17mr5013864ita.20.1554391025933;
        Thu, 04 Apr 2019 08:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0zF63Iv/eSegV54GVQfLnwThhuuUm1/fU1SR9MLlSfaD9WB7xrXiICAi4xRKCwlMKjkSu
X-Received: by 2002:a24:4511:: with SMTP id y17mr5013764ita.20.1554391024605;
        Thu, 04 Apr 2019 08:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554391024; cv=none;
        d=google.com; s=arc-20160816;
        b=vgmhNoWpU2U+WhtCL1sicvLBHE+yJ6TV7ZLn8kYu9c93LdKDTVjrUUEnEsOKAPsD0S
         UpadlSoQck9KcpceclECP/W+mtO0z2M6vi8G8pqdAWZA0tejo3FvyPU1ukJwU1r819jS
         4hLF8wn7N/qLyzLR/vziW2Mu/F+2tUIVXM/Ui+EVhX+1CfRSmcaLDTcH9ZwIO+qvFyGe
         pECk22l2iMaoCXWoZybggeyepYym/zj0SgrmcpNG0U0t7gLUkQsMKCWYErHU2tI0T5mM
         XyQk/4/u9kD2RSaKpAorAGpbfA9Q40wT00rW+191iKuyek7FbrZa6Kc8W2knWXZps/0b
         5ALA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=MR9XSpEeqL8KNMIKhJwqaUWQnfjgzJVyCNhDLZ5BgCk=;
        b=vad8NFgU133ZeJzyUH7afTZoVyKpr0uCtldCfV4nZJ9OCBwvznUE3vtmrHrs6deed2
         Fwz8IYUra3rdkCF28XAwHkiOb5aMoVMlHtcu0iH3cWgm5nbFXknklmFL3mdCmPbBf87+
         PQ7wByXD37U6RRhm4XWccr3XUZ8Dk7DT+z6FUUrv5D85FX9RtdaWpdsDf+b6YImlEOYk
         BKHN41J9qos8LFmI9ulYP1n6In8PDxC0seLPVJ5aoyUxJ0GCEA9fP2TYPzwVmSh6KEFv
         MgVA5Q0dGuE1ibYBKYyw0/K2e+AHiOBBL3pkG8lVKPK7A81lTCS4DFw9YTQ+sHfTPZ+8
         bcig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RkpJHFBw;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x184si10220927itb.112.2019.04.04.08.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 08:17:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RkpJHFBw;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34F91UB040163;
	Thu, 4 Apr 2019 15:16:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=MR9XSpEeqL8KNMIKhJwqaUWQnfjgzJVyCNhDLZ5BgCk=;
 b=RkpJHFBwhjUx9DiNymwuYUDfDWv5KUgxun55miuqeI/JGSdS/TRhb0+ar5K4Tt0ogtSy
 9F/dibDpB/4IDOIqBVtiUs8cL44AlGyoRz3GGonIZlZabDmeP7QfxT1Z+CI3XrJAdS5I
 tf9s5lqYstekZ04dHdQmvCK5nbOXqpkVf88iCcuoVPbILS9gvj9Ug6Lk0544e0hr+I0w
 iVospW8vRQNO1iLX/MB+pAt+cAqmJoDXWJvbbN0L3SGfGGHhhLQ55K0X/3WQHzN+gY6W
 ouGxxsgRO2fzQ1e/XoNsn8gU4O8acgEpaz3/UguU1uZ6Vp9xCeSCzFoZZeIy1KDFx58a fA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rj13qfq7w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 15:16:07 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34FFdIX123631;
	Thu, 4 Apr 2019 15:16:06 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2rm8f6r1f4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 15:16:06 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x34FFs2U009068;
	Thu, 4 Apr 2019 15:15:55 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 08:15:53 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Peter Zijlstra <peterz@infradead.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190404074323.GO4038@hirez.programming.kicks-ass.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <b414bacc-2883-1914-38ec-3d8f4a032e10@oracle.com>
Date: Thu, 4 Apr 2019 09:15:46 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190404074323.GO4038@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=996
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040098
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=989 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/4/19 1:43 AM, Peter Zijlstra wrote:
>=20
> You must be so glad I no longer use kmap_atomic from NMI context :-)
>=20
> On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
>> +static inline void xpfo_kmap(void *kaddr, struct page *page)
>> +{
>> +	unsigned long flags;
>> +
>> +	if (!static_branch_unlikely(&xpfo_inited))
>> +		return;
>> +
>> +	if (!PageXpfoUser(page))
>> +		return;
>> +
>> +	/*
>> +	 * The page was previously allocated to user space, so
>> +	 * map it back into the kernel if needed. No TLB flush required.
>> +	 */
>> +	spin_lock_irqsave(&page->xpfo_lock, flags);
>> +
>> +	if ((atomic_inc_return(&page->xpfo_mapcount) =3D=3D 1) &&
>> +		TestClearPageXpfoUnmapped(page))
>> +		set_kpte(kaddr, page, PAGE_KERNEL);
>> +
>> +	spin_unlock_irqrestore(&page->xpfo_lock, flags);
>=20
> That's a really sad sequence, not wrong, but sad. _3_ atomic operations=
,
> 2 on likely the same cacheline. And mostly all pointless.
>=20
> This patch makes xpfo_mapcount an atomic, but then all modifications ar=
e
> under the spinlock, what gives?
>=20
> Anyway, a possibly saner sequence might be:
>=20
> 	if (atomic_inc_not_zero(&page->xpfo_mapcount))
> 		return;
>=20
> 	spin_lock_irqsave(&page->xpfo_lock, flag);
> 	if ((atomic_inc_return(&page->xpfo_mapcount) =3D=3D 1) &&
> 	    TestClearPageXpfoUnmapped(page))
> 		set_kpte(kaddr, page, PAGE_KERNEL);
> 	spin_unlock_irqrestore(&page->xpfo_lock, flags);
>=20
>> +}
>> +
>> +static inline void xpfo_kunmap(void *kaddr, struct page *page)
>> +{
>> +	unsigned long flags;
>> +
>> +	if (!static_branch_unlikely(&xpfo_inited))
>> +		return;
>> +
>> +	if (!PageXpfoUser(page))
>> +		return;
>> +
>> +	/*
>> +	 * The page is to be allocated back to user space, so unmap it from
>> +	 * the kernel, flush the TLB and tag it as a user page.
>> +	 */
>> +	spin_lock_irqsave(&page->xpfo_lock, flags);
>> +
>> +	if (atomic_dec_return(&page->xpfo_mapcount) =3D=3D 0) {
>> +#ifdef CONFIG_XPFO_DEBUG
>> +		WARN_ON(PageXpfoUnmapped(page));
>> +#endif
>> +		SetPageXpfoUnmapped(page);
>> +		set_kpte(kaddr, page, __pgprot(0));
>> +		xpfo_flush_kernel_tlb(page, 0);
>=20
> You didn't speak about the TLB invalidation anywhere. But basically thi=
s
> is one that x86 cannot do.
>=20
>> +	}
>> +
>> +	spin_unlock_irqrestore(&page->xpfo_lock, flags);
>=20
> Idem:
>=20
> 	if (atomic_add_unless(&page->xpfo_mapcount, -1, 1))
> 		return;
>=20
> 	....
>=20
>=20
>> +}
>=20
> Also I'm failing to see the point of PG_xpfo_unmapped, afaict it
> is identical to !atomic_read(&page->xpfo_mapcount).
>=20

Thanks Peter. I really appreciate your review. Your feedback helps make
this code better and closer to where I can feel comfortable not calling
it RFC any more.

The more I look at xpfo_kmap()/xpfo_kunmap() code, the more I get
uncomfortable with it. As you pointed out about calling kmap_atomic from
NMI context, that just makes the kmap_atomic code look even worse. I
pointed out one problem with this code in cover letter and suggested a
rewrite. I see these problems with this code:

1. When xpfo_kmap maps a page back in physmap, it opens up the ret2dir
attack security hole again even if just for the duration of kmap. A kmap
can stay around for some time if the page is being used for I/O.

2. This code uses spinlock which leads to problems. If it does not
disable IRQ, it is exposed to deadlock around xpfo_lock. If it disables
IRQ, I think it can still deadlock around pgd_lock.

I think a better implementation of xpfo_kmap()/xpfo_kunmap() would map
the page at a new virtual address similar to what kmap_high for i386
does. This avoids re-opening the ret2dir security hole. We can also
possibly do away with xpfo_lock saving bytes in page-frame and the not
so sane code sequence can go away.

Good point about PG_xpfo_unmapped flag. You are right that it can be
replaced with !atomic_read(&page->xpfo_mapcount).

Thanks,
Khalid

