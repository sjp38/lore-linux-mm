Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB89FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:04:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8329820675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:04:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8329820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17ADC6B000A; Wed,  8 May 2019 07:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12C2F6B000C; Wed,  8 May 2019 07:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F34896B000D; Wed,  8 May 2019 07:04:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE4A86B000A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:04:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id z130so37316915ywb.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:04:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=++RW+Yq1VggbO0WQlCZcVrG5WQFJ+c3J3ekC2wplYd4=;
        b=Z843JeCyoNEeuBHFOy1ZyleUwvX9+8Mb6orQCYrTBKntPctETBWxfu1Ti3Fxnj8em9
         1Fyta5sWq08R/rPgqPr47Z2+ftrBK2Q8F/d9MP3wT3zrpnySWJQM/Ga8y1YUd6vrnJwQ
         jGkQaRkiLhvHgL+n9H88SRzVq6gHsx3HgIMBTqv5hC5mbCGrFFff/4qRuuPIo0gM2/K2
         fHOORHX+2NxHjrJaFHzQ85vvm+Kh5LP3NzeWA0B1WJRFNNgiGt3KORXBl8btnJwvJ3xK
         Pb9zjotxooFH3IyZBAyAQt07ReHHfmaJUTNndchLSGKAnBrdtbUQzFOsByf6MWaRS6mx
         JE9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXzt7CQYP62BIdHLZinvaCmvOMyMDPBInA6prsZlgxFHspBFSFp
	chB3q6Wvp0BGd4UOUcSqaSa6XKwv5XTBlYPVsGx2Y7FwAfbhKJp5sk/hC7PiVZ3Omn8+7jkWAob
	98VOEoq0HhTKtJQVMWMiCtAxRXkc3HjCEX6wAih3TE3Z1FUBdCpRV+stpTzUyRs+n8w==
X-Received: by 2002:a81:2f4e:: with SMTP id v75mr25671322ywv.14.1557313457563;
        Wed, 08 May 2019 04:04:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZNe9TKVTfFb9j74acoCnVmFRHL3ZI+vpLOIq9AzR3HZlECRqqrbVv8en8mCQHTPefYKBp
X-Received: by 2002:a81:2f4e:: with SMTP id v75mr25671270ywv.14.1557313456836;
        Wed, 08 May 2019 04:04:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557313456; cv=none;
        d=google.com; s=arc-20160816;
        b=F+7sLEOn0h290fCdZ4ATwiANZ6RNiOBEFyQaeu9j/RanKRUFnwO/5D53gR5BdMul2o
         vyl2LxInS0h9rwr+AkbbkQO4rI4I2JCcVJxnUaCzDalm6frmoYHfVJWVvN8FYahNQvhY
         urG0HwR2RDkTfpZOLmg9KHFaSQjNuRIXxdWfD21o0KIhnQCv+2EHUkLW481JYqPg94I6
         +zs+g18Ak+f43gOZxIOUIsBOx7rtVc+Ux3wKXpOfI9gZVIQJtMTjtJuAUcmqTcIXcVey
         GwDxQyqGGHoZdWhHNV7wsJfCpmWbh45o5XKNMZoRGU14qlAGCrUOG2xcUdbB7O2d+4tv
         XMIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:subject:cc:to:from:date;
        bh=++RW+Yq1VggbO0WQlCZcVrG5WQFJ+c3J3ekC2wplYd4=;
        b=HAEQ13xbWHdUPvZnkXRgn9vMMxVDBIvGo/5KgigeH7+d8RJ/i59DajB9+ICmPSOA1f
         y2AZL8DTFa14iZjfmJkbjK3SO0ICL7zc6bHyVvSf77GI23b5Sfa5f7hRjC0noilDRbSD
         87GF1uPa4W5GybHl0UV1BBGbp7FqpbI+wiL2fasZyMCfkMr/J4AMlDTEzC1nDsAfp5Q7
         q+R7NVxS65Gpfsy4dUxCkVGfIddXNEh+CEoYJpjFJKcGvz0L4rTgCX1Gw6iYM95UYIK4
         ypi+Phj1c98skiPHFYvTUHegMZ7+xL7WYdjYZaGAM6nNud2zlCXGilqRjF4lE+obOYPs
         /0AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f11si6495239ywb.70.2019.05.08.04.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 04:04:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48B30TR128996
	for <linux-mm@kvack.org>; Wed, 8 May 2019 07:04:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbucrqvb0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 07:04:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 8 May 2019 12:04:14 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 12:04:09 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x48B48wv58327292
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 11:04:08 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2CB9AAE056;
	Wed,  8 May 2019 11:04:08 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 84F9DAE058;
	Wed,  8 May 2019 11:04:07 +0000 (GMT)
Received: from thinkpad (unknown [9.152.212.151])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed,  8 May 2019 11:04:07 +0000 (GMT)
Date: Wed, 8 May 2019 13:04:06 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Sasha Levin <sashal@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Alexander Duyck
 <alexander.duyck@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>, stable
 <stable@vger.kernel.org>,
        Mikhail Zaslonko <zaslonko@linux.ibm.com>,
        Michal
 Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
        Mikhail Gavrilov
 <mikhail.v.gavrilov@gmail.com>,
        Dave Hansen <dave.hansen@intel.com>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Pasha Tatashin
 <Pavel.Tatashin@microsoft.com>,
        Martin Schwidefsky
 <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Sasha Levin
 <alexander.levin@microsoft.com>,
        linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize
 struct pages for the full memory section
In-Reply-To: <20190507171806.GG1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
	<20190507053826.31622-62-sashal@kernel.org>
	<CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
	<CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
	<20190507170208.GF1747@sasha-vm>
	<CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
	<20190507171806.GG1747@sasha-vm>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19050811-0016-0000-0000-000002798757
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050811-0017-0000-0000-000032D63610
Message-Id: <20190508130406.3c9237c1@thinkpad>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1031 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080071
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2019 13:18:06 -0400
Sasha Levin <sashal@kernel.org> wrote:

> On Tue, May 07, 2019 at 10:15:19AM -0700, Linus Torvalds wrote:
> >On Tue, May 7, 2019 at 10:02 AM Sasha Levin <sashal@kernel.org> wrote:
> >>
> >> I got it wrong then. I'll fix it up and get efad4e475c31 in instead.
> >
> >Careful. That one had a bug too, and we have 891cb2a72d82 ("mm,
> >memory_hotplug: fix off-by-one in is_pageblock_removable").
> >
> >All of these were *horribly* and subtly buggy, and might be
> >intertwined with other issues. And only trigger on a few specific
> >machines where the memory map layout is just right to trigger some
> >special case or other, and you have just the right config.
> >
> >It might be best to verify with Michal Hocko. Michal?
> 
> Michal, is there a testcase I can plug into kselftests to make sure we
> got this right (and don't regress)? We care a lot about memory hotplug
> working right.

We hit the panics on s390 with special z/VM memory layout, but they both
can be triggered simply by using mem= kernel parameter (and
CONFIG_DEBUG_VM_PGFLAGS=y).

With "mem=3075M" (and w/o the commits efad4e475c31 + 24feb47c5fa5), it
can be triggered by reading from
/sys/devices/system/memory/memory<x>/valid_zones, or from
/sys/devices/system/memory/memory<x>/removable, with <x> being the last
memory block.

This is with 256MB section size and memory block size. On LPAR, with
256MB section size and 1GB memory block size, for some reason the
"removable" issue doesn't trigger, only the "valid_zones" issue.

Using lsmem will also trigger it, as it reads both the valid_zones and
the removable attribute for all memory blocks. So, a test with
not-section-aligned mem= parameter and using lsmem could be an option.

Regards,
Gerald

