Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D204C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:39:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C05F21743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:39:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C05F21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAB616B0003; Wed, 17 Jul 2019 01:39:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5C9D8E0001; Wed, 17 Jul 2019 01:39:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C23876B0006; Wed, 17 Jul 2019 01:39:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C79C6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:39:08 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id r7so11457037plo.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 22:39:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=KTphljT76NaHnlTKlaaGDxJ2qjFJc1NysIEnorw109E=;
        b=dHhKSXY0fzOugGo+zaMPMzhz3gHBaoenkNEb/3jy3yvdY61IFNvT/jts2gl9gNsI4D
         GY7v87Wz27PuDggrt4KKmV7hJorYPZxrf9jiO4a+dm8Qtx9Tq+Di05+VQl5SABM3wAmq
         Jzomhz3qHJPTeObJnU6srh9ASYxmIpzQNy2qpWGAVJKcnINAvPeFgY/zmJJGwu3611YN
         phcttkGaQTj00rNPkQWxwoPLpuO7EaXhYZ4/ZtEWzUUhw9jdkI7hIjQtBO0OcXvMpLFX
         PAFNTa6qSCgsIRqoM3NY4r4t1Z5LO1J3s8tRUtGBrLT7lmaA0XTI5sNGd4Wo3OlUTLdu
         MQ7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUZlraFFjzr9sAFvMstxL7LTsn69A0k19006q9XDvxhETbIkyP1
	9legeSPuZFPRN39HEZAyKoeCMVDeqnZ/YLb0tEMntDi2C2ES3xCfzzlLwEAKCKPrrhQ/uwvjlqc
	EHAqJqTnmw5tWhinIGFIc+5MIkmBwqJnrMf4BZCOMmL9Wu5y44/IF8aWkPn2UvGMrsw==
X-Received: by 2002:a17:90a:9b08:: with SMTP id f8mr42054112pjp.103.1563341948231;
        Tue, 16 Jul 2019 22:39:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFHo5PAyxAJTKdMxZojX21LguSbyqfRS9097+9/kxyfAq6lWlwBgdhRzjI3CVGEDBayNVL
X-Received: by 2002:a17:90a:9b08:: with SMTP id f8mr42054047pjp.103.1563341947477;
        Tue, 16 Jul 2019 22:39:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563341947; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGTijG1N+Gl8XLxzXgZTkANTJWlPmdsy+7IM7S2NgGBnjdRLS82IhyqFYeEAB2v4dV
         p+dwZmPupD9qpsMIGgne4rehSFHGE1vf6wFWw4e+UxQVCiFC+21IavKGk5ym5I6DQlEL
         n8vfgeTe0DXj2INOSNFeHl5ZXtav399aBwEeCIQKNEkuL+5UJThammgGJfBiuTuae+jW
         gyn4WW4jt2pcPnMn0QwYdZxHNn/SlxAqiS1MsPfcmdfksAOFf9giWI9Vhjk7VFuETLED
         bs7B+Vim72CA3cjWoSvawMOZ/dSMa/iX+XE1CjQz6TDXX7W1OetQ4QJi0krTdNQGONa/
         G6lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=KTphljT76NaHnlTKlaaGDxJ2qjFJc1NysIEnorw109E=;
        b=0NL5xyo/9pieeyNs6iayMDiHLFc52YSRK29oPkkueimpC9dn+QDuxn4Yr0ydWR6DsK
         OqUTuFiMpfSDH6mNuLElwgjZP0dMYw7yZhrtpdRWN3ZrVzc8J01K9QcbmmlrBFYp+hTr
         BcEnn82wToYwA2UTop5G1Z7Tz/NkAI1U0vAxtPNxIJb+DGALTVyUIgOjokKmYsJ4muSr
         UJDoqNdH9VYkX7zqGyiy+xwWNOZW1RZg2hj0vWrAvuEbeW+HQfK9CDV9GGOxGjnDX8gJ
         6jk0ui3nkvWIUvHpZyM+7PN3qbFXxCjX6xjgoehcx+O3DivcxSB0rHSPDHk/KvvjDTEs
         pX6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t9si21233000pji.69.2019.07.16.22.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 22:39:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6H5bYCH101721
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:39:05 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tsurwv7h9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:39:05 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 17 Jul 2019 06:39:02 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 17 Jul 2019 06:38:59 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6H5cwd743843590
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Jul 2019 05:38:58 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F244F11C052;
	Wed, 17 Jul 2019 05:38:57 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7A03411C04A;
	Wed, 17 Jul 2019 05:38:56 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.35.18])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 17 Jul 2019 05:38:56 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, david@redhat.com, pasha.tatashin@soleen.com,
        mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
In-Reply-To: <1563225851.3143.24.camel@suse.de>
References: <20190715081549.32577-1-osalvador@suse.de> <20190715081549.32577-3-osalvador@suse.de> <87tvbne0rd.fsf@linux.ibm.com> <1563225851.3143.24.camel@suse.de>
Date: Wed, 17 Jul 2019 11:08:54 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19071705-0008-0000-0000-000002FE32CD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071705-0009-0000-0000-0000226BAB32
Message-Id: <87o91tcj9t.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-17_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907170069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Oscar Salvador <osalvador@suse.de> writes:

> On Mon, 2019-07-15 at 21:41 +0530, Aneesh Kumar K.V wrote:
>> Oscar Salvador <osalvador@suse.de> writes:
>> 
>> > Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION
>> > granularity.
>> > The problem is that deactivation of the section occurs later on in
>> > sparse_remove_section, so pfn_valid()->pfn_section_valid() will
>> > always return
>> > true before we deactivate the {sub}section.
>> 
>> Can you explain this more? The patch doesn't update section_mem_map
>> update sequence. So what changed? What is the problem in finding
>> pfn_valid() return true there?
>
> I realized that the changelog was quite modest, so a better explanation
>  will follow.
>
> Let us analize what shrink_{zone,node}_span does.
> We have to remember that shrink_zone_span gets called every time a
> section is to be removed.
>
> There can be three possibilites:
>
> 1) section to be removed is the first one of the zone
> 2) section to be removed is the last one of the zone
> 3) section to be removed falls in the middle
>  
> For 1) and 2) cases, we will try to find the next section from
> bottom/top, and in the third case we will check whether the section
> contains only holes.
>
> Now, let us take the example where a ZONE contains only 1 section, and
> we remove it.
> The last loop of shrink_zone_span, will check for {start_pfn,end_pfn]
> PAGES_PER_SECTION block the following:
>
> - section is valid
> - pfn relates to the current zone/nid
> - section is not the section to be removed
>
> Since we only got 1 section here, the check "start_pfn == pfn" will make us to continue the loop and then we are done.
>
> Now, what happens after the patch?
>
> We increment pfn on subsection basis, since "start_pfn == pfn", we jump
> to the next sub-section (pfn+512), and call pfn_valid()-
>>pfn_section_valid().
> Since section has not been yet deactivded, pfn_section_valid() will
> return true, and we will repeat this until the end of the loop.
>
> What should happen instead is:
>
> - we deactivate the {sub}-section before calling
> shirnk_{zone,node}_span
> - calls to pfn_valid() will now return false for the sections that have
> been deactivated, and so we will get the pfn from the next activaded
> sub-section, or nothing if the section is empty (section do not contain
> active sub-sections).
>
> The example relates to the last loop in shrink_zone_span, but the same
> applies to find_{smalles,biggest}_section.
>
> Please, note that we could probably do some hack like replacing:
>
> start_pfn == pfn 
>
> with
>
> pfn < end_pfn

Why do you consider this a hack? 

 /* If the section is current section, it continues the loop */
	if (start_pfn == pfn)
		continue;

The comment explains that check is there to handle the exact scenario
that you are fixing in this patch. With subsection patch that check is
not sufficient. Shouldn't we just fix the check to handle that?

Not sure about your comment w.r.t find_{smalles,biggest}_section. We
search with pfn range outside the subsection we are trying to remove.
So this should not have an impact there?


>
> But the way to fix this is to 1) deactivate {sub}-section and 2) let
> shrink_{node,zone}_span find the next active {sub-section}.
>
> I hope this makes it more clear.

-aneesh

