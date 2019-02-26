Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C60FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7772146F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:12:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7772146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 305A98E0003; Tue, 26 Feb 2019 06:12:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B5E48E0001; Tue, 26 Feb 2019 06:12:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17F3B8E0003; Tue, 26 Feb 2019 06:12:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE8358E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:12:12 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 17so9353740pgw.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:12:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=YxHXkrEV7ESPBwEfQscaIAoOG80d5js6lj4v7Hk+Q8E=;
        b=LbU3/tX5pMhbD4LcULafQkmBlykUAU71/OevnDZ4M8VrFi67+MBGb2SNDwKmE4/P0r
         bB37RLywJ8hOIwWAVXe2TbrFY7OQ+49oMINfgu169DlPj0yaj91YaIVfmUVhoiPqdxZ6
         xHqxG9bpxEFJ3VNPJMTU1RR5rbVfuVd4kxq/IqludekLx49BaZ+CPnCynxprFqVN2D8l
         gZLH33XgyJ0d8mQpK5id5/oJFOKwhNMulqaspGrDuB2YtJwfz/QfERFCYRCB1sAB94WD
         NwXNq2tn8EaeJlIGDmfycpRI+3TbvXAQSaNgNhUYYicNRPIQTkKzaClqYaczdSbZN4Ch
         sAKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubvOIaquv6fxPY9Id2Er/yMXUN7gAIT1pIQKEiUYl09nilkPWmH
	5tm02aTV6YirriF0ts0QeuGmPxkcdHwRH2PBiat/Q76IHzdfncL6vHPX/gIIN/o/x+52az5GgXB
	mOmmcAw0QKz9DKAW4ahhgDKWyDBVOBKv9I0JObILo5SwpigrSrZKes+COTXsjdtYEEQ==
X-Received: by 2002:a62:445a:: with SMTP id r87mr25028713pfa.13.1551179532353;
        Tue, 26 Feb 2019 03:12:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayeRedoHbu91Ii1A7Zza5kOm3WhSADBTt/oquA2QTrkeO1rEAyENFdSc/x9zof6bCEkRLM
X-Received: by 2002:a62:445a:: with SMTP id r87mr25028634pfa.13.1551179531246;
        Tue, 26 Feb 2019 03:12:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551179531; cv=none;
        d=google.com; s=arc-20160816;
        b=PbpSXs7s+tLy/HPT+UBo0+kX3NOo0D7BB3dCoBOXhgN2sv2fjGlLO+LahQ4dmXiJ8p
         ccpkI5PvQkTo8h0QHMMMGBfRRHiwNhZXv0YgDuCOxCBKrTvCyDEVRVfrvs4LeWzQ3Luj
         F2gY6a7oGQOAg4CHhDryHKQNNAgUSkrPN0WXbof+CZExZpySVHTH5F0UjSIy9OLxceyN
         1fP4uzpdx2YHHOeUU0z3whTztGFfD6htB6V9k+6c3zYA1ycGSQ41AQ8riUnhAz20lehe
         65ZneJwd6sH1tX2AGOpl5R64CA3FAsqMK+q3RKCZ3y3w0I2XC3+JwNPT+X3Qgj3JUDLY
         EEnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=YxHXkrEV7ESPBwEfQscaIAoOG80d5js6lj4v7Hk+Q8E=;
        b=t/6L7awqNgFYsx4P29aBjBlZ4dJuFVM0+LKellPQuFfbzZ6cHMBK+d7Zw1iSPIFAAY
         ZxDLIoRZk9KO/k8a0aqhII5n3O9cVLef8VU2p0TxkMzbVJ5yw80mH81+DMEQUQBfM51m
         9t93yciaRMAaD4rZaCjqap/Qq5OpleKGF59FoMnXkUiRL1M40I7Dg1/82RSPtAut5w6q
         AFOTyW9nbo4mWCI5FARQi4jZ8bEz3Ut/ZQdWqGEfbXPoDmvWnJm24aq/Rsg9BGLBdP+E
         06w+990eC80wfUgZu+JywJZ4tr/O+gseXLRirLX+9RBpKf2oMsSOeUTaw2EnKCh2jfox
         MN1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t24si11246199pgv.141.2019.02.26.03.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 03:12:11 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1QBBhxU053101
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:12:10 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qw3n4tq4w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:12:09 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 11:12:07 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 11:12:02 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1QBC1eB31064226
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 11:12:01 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 74FAB42041;
	Tue, 26 Feb 2019 11:12:01 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BB7542042;
	Tue, 26 Feb 2019 11:12:00 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 11:12:00 +0000 (GMT)
Date: Tue, 26 Feb 2019 13:11:58 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peng Fan <peng.fan@nxp.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "labbott@redhat.com" <labbott@redhat.com>,
        "mhocko@suse.com" <mhocko@suse.com>,
        "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
        "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
        "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
        "rdunlap@infradead.org" <rdunlap@infradead.org>,
        "andreyknvl@google.com" <andreyknvl@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
References: <20190214125704.6678-1-peng.fan@nxp.com>
 <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
 <b78470e8-b204-4a7e-f9cc-eff9c609f480@suse.cz>
 <20190219174610.GA32749@rapoport-lnx>
 <AM0PR04MB448139C6E264579818E94CF6887F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB448139C6E264579818E94CF6887F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022611-0028-0000-0000-0000034D2B68
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022611-0029-0000-0000-0000240B7E14
Message-Id: <20190226111158.GF11981@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 12:55:41PM +0000, Peng Fan wrote:
> 
> 
> > -----Original Message-----
> > From: Mike Rapoport [mailto:rppt@linux.ibm.com]
> > Sent: 2019年2月20日 1:46
> > To: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Andrew Morton <akpm@linux-foundation.org>; Peng Fan
> > <peng.fan@nxp.com>; labbott@redhat.com; mhocko@suse.com;
> > iamjoonsoo.kim@lge.com; rppt@linux.vnet.ibm.com;
> > m.szyprowski@samsung.com; rdunlap@infradead.org;
> > andreyknvl@google.com; linux-mm@kvack.org; linux-kernel@vger.kernel.org;
> > van.freenix@gmail.com; Catalin Marinas <catalin.marinas@arm.com>
> > Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
> > 
> > On Tue, Feb 19, 2019 at 05:55:33PM +0100, Vlastimil Babka wrote:
> > > On 2/14/19 9:38 PM, Andrew Morton wrote:
> > > > On Thu, 14 Feb 2019 12:45:51 +0000 Peng Fan <peng.fan@nxp.com>
> > wrote:
> > > >
> > > >> In case cma_init_reserved_mem failed, need to free the memblock
> > > >> allocated by memblock_reserve or memblock_alloc_range.
> > > >>
> > > >> ...
> > > >>
> > > >> --- a/mm/cma.c
> > > >> +++ b/mm/cma.c
> > > >> @@ -353,12 +353,14 @@ int __init
> > cma_declare_contiguous(phys_addr_t
> > > >> base,
> > > >>
> > > >>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name,
> > res_cma);
> > > >>  	if (ret)
> > > >> -		goto err;
> > > >> +		goto free_mem;
> > > >>
> > > >>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
> > > >>  		&base);
> > > >>  	return 0;
> > > >>
> > > >> +free_mem:
> > > >> +	memblock_free(base, size);
> > > >>  err:
> > > >>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
> > > >>  	return ret;
> > > >
> > > > This doesn't look right to me.  In the `fixed==true' case we didn't
> > > > actually allocate anything and in the `fixed==false' case, the
> > > > allocated memory is at `addr', not at `base'.
> > >
> > > I think it's ok as the fixed==true path has "memblock_reserve()", but
> > > better leave this to the memblock maintainer :)
> > 
> > As Peng Fan noted in the other e-mail, fixed==true has memblock_reserve()
> > and fixed==false resets base = addr, so this is Ok.
> > 
> > > There's also 'kmemleak_ignore_phys(addr)' which should probably be
> > > undone (or not called at all) in the failure case. But it seems to be
> > > missing from the fixed==true path?
> > 
> > Well, memblock and kmemleak interaction does not seem to have clear
> > semantics anyway. memblock_free() calls kmemleak_free_part_phys() which
> > does not seem to care about ignored objects.
> > As for the fixed==true path, memblock_reserve() does not register the area
> > with kmemleak, so there would be no object to free in memblock_free().
> > AFAIU, kmemleak simply ignores this.
> 
> I also go through the memblock_free flow, and agree with Mike
> memblock_free 
>     -> kmemleak_free_part_phys 
>           -> kmemleak_free_part
>                  |-> delete_object_part
>                          |-> object = find_and_remove_object(ptr, 1);
> 
> memblock_reserve not register the area in kmemleak, so find_and_remove_object
> will not be able to find a valid area and just return.
> 
> What should I do next with this patch?
 
I'd suggest to wait for Catalin to review it.

I think it's also worth making the changelog more elaborate and include the
details we've discussed in this thread.

> Thanks,
> Peng.
> 
> > 
> > Catalin, can you comment please?
> > 
> > --
> > Sincerely yours,
> > Mike.
> 

-- 
Sincerely yours,
Mike.

