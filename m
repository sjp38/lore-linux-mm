Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57F33C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:15:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13EB02053B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:15:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13EB02053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 956B96B0005; Tue,  7 May 2019 13:15:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 908266B0006; Tue,  7 May 2019 13:15:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81E606B0007; Tue,  7 May 2019 13:15:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6A36B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:15:38 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s8so10732665pgk.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:15:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=qeXp0CvAOO0tXPkoJ3JuRLNAFOo6M/kKB8bDFRWtMYQ=;
        b=sjWfzc9VV9FbAAqfW8cX+3/gRl4WdDcr+0xz8AvMHuUU6E5SeCpC/PNNj4BTmzn4Ot
         DtV5RaBHcqSnKl6b/Uy5JsJmKchi3A9OOck6tvFkpLitxhOD/uyUbohGLNhNNjY//X37
         mgQ1QRPNZ/7lPnFrVjFrFBFvFLgYKTt64/5rJjZMi3XL4vuVhFN5+oa5BZJ1MxqYiI+l
         6bsuz+cDl6CxQEET19rs73knZqfHiLAwWoSekNiEM2NioTK5fifog+/OkQ8/MtdPc6p8
         5XKSm9Gw6lLyUQnKjHbpHMp9bGhVpAhtSsEFQYmeXb25O9EJFw2ZTzBq+VdgHpcufdY1
         s0gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX+VFa6EGyeFEL7jMT5+YDGNW7cVDby5uMOnE5KIgsruso8e6ZG
	yifVJDuZ9prtRM9nB8K16RJLMlPgC5QSK+/W5JwoHUHLVLcytKkWR61u1ZrXwyOR693VzmfRnUr
	4QPKBgWn7pKIavW3QdNkDuiKjL2GLKD7vIEq3k40fsmO4Acyh8m7Q9hq/e71Biq3Itg==
X-Received: by 2002:a17:902:8f88:: with SMTP id z8mr40591393plo.54.1557249337983;
        Tue, 07 May 2019 10:15:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKnEizKSeShq/dtzcJB0/QHLCKq3e/J95vXGosjXaNbxl+K2BhUA5Xigk8u+jvQuOMkOqf
X-Received: by 2002:a17:902:8f88:: with SMTP id z8mr40591337plo.54.1557249337449;
        Tue, 07 May 2019 10:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249337; cv=none;
        d=google.com; s=arc-20160816;
        b=y+aqTOeQOFEvzND88OmLdnGNqO+1P2eJcLmavlakA2KK6YCtjBKv369vNMRyLwbgKN
         CWD+JGRVYbHf4ENteM9WI6QlCdFfCrfIYJyWEW7AxfT12wVJcF3a9XZx7sWTPiYKUOnW
         oqSmrL/HwawG85h45F4UW0YxEQx5MDCfAJ7kS81T6bYmtUfF2/OdwEucNuSl0QDbozUM
         9pYK/yd4z9IPhgMd7t1rWmwl/kItM2VqnNHrOLWTmemw9IHBQC7uQsFUdmiNFKxHI3f1
         XyKcTpsP7qxCwLKWh4ktZoL7DpFs2ydaGqu7ZxjhNVjQUKKAqddLpde0kFXKWLHI5Cl8
         0m+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:subject:cc:to:from:date;
        bh=qeXp0CvAOO0tXPkoJ3JuRLNAFOo6M/kKB8bDFRWtMYQ=;
        b=1Bim3KeHXITwbyZ1/YQZ4Gp1fbU7iQdsoWvjUKwF9iBh0PRiJO8wwSalqISJkGuOib
         3tn38y9cMKkJikCm1vS+gauJENO5EKSM0eYPlGlmnKtd8qNsvvWHFZ7uFgHgwKbn4FRd
         KMriI31LkQPa5mWxtJILpQAs3NVvz8U4658N9w6cqK9liyshsB4SdYjWQNWNG7l509H8
         MWhHMs72o4VSOxgx7n+I1zVnbtlu+FoTSOhMz7wRu6v8alXCuz20YtzVYyi2v0UYoS2F
         wCgeKsipkeE8wBBHriuAst6mOCE1Tr/+fQZNb4NwuZi6cMhsA5Ypjpblmj8/Et8pF2C/
         wlag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i2si15645251pgi.0.2019.05.07.10.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x47HF26w083716
	for <linux-mm@kvack.org>; Tue, 7 May 2019 13:15:36 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbd0x3k5v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 May 2019 13:15:19 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 7 May 2019 18:13:07 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 7 May 2019 18:13:02 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x47HD1lY39846070
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 7 May 2019 17:13:01 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A1037A405B;
	Tue,  7 May 2019 17:13:01 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 28C49A4060;
	Tue,  7 May 2019 17:13:01 +0000 (GMT)
Received: from thinkpad (unknown [9.152.212.151])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  7 May 2019 17:13:01 +0000 (GMT)
Date: Tue, 7 May 2019 19:13:00 +0200
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
In-Reply-To: <20190507170208.GF1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
	<20190507053826.31622-62-sashal@kernel.org>
	<CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
	<CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
	<20190507170208.GF1747@sasha-vm>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19050717-0008-0000-0000-000002E43CCF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050717-0009-0000-0000-00002250BAE6
Message-Id: <20190507191300.6e653799@thinkpad>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-07_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1031 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=922 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905070111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2019 13:02:08 -0400
Sasha Levin <sashal@kernel.org> wrote:

> On Tue, May 07, 2019 at 09:50:50AM -0700, Linus Torvalds wrote:
> >On Tue, May 7, 2019 at 9:31 AM Alexander Duyck
> ><alexander.duyck@gmail.com> wrote:
> >>
> >> Wasn't this patch reverted in Linus's tree for causing a regression on
> >> some platforms? If so I'm not sure we should pull this in as a
> >> candidate for stable should we, or am I missing something?
> >
> >Good catch. It was reverted in commit 4aa9fc2a435a ("Revert "mm,
> >memory_hotplug: initialize struct pages for the full memory
> >section"").
> >
> >We ended up with efad4e475c31 ("mm, memory_hotplug:
> >is_mem_section_removable do not pass the end of a zone") instead (and
> >possibly others - this was just from looking for commit messages that
> >mentioned that reverted commit).
> 
> I got it wrong then. I'll fix it up and get efad4e475c31 in instead.

There were two commits replacing the reverted commit, fixing
is_mem_section_removable() and test_pages_in_a_zone() respectively:

commit 24feb47c5fa5 ("mm, memory_hotplug: test_pages_in_a_zone do not
pass the end of zone")
commit efad4e475c31 ("mm, memory_hotplug: is_mem_section_removable do
not pass the end of a zone")

