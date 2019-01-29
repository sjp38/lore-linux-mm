Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2946C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 883F82147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:08:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 883F82147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FA008E0002; Tue, 29 Jan 2019 09:08:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AB0A8E0001; Tue, 29 Jan 2019 09:08:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB52B8E0002; Tue, 29 Jan 2019 09:08:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB4AC8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:08:16 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so21950890qkb.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:08:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:references:mime-version:message-id
         :content-transfer-encoding;
        bh=UH9CvHGKidG0zSad9i9agr3dX9d9QROln7gglTCOaQU=;
        b=eGEgVtIHpOUk1uVjqriFEBTDGUQ+n7ofotb9BSqklVF18ywEtiRNnFg39ZWjsrTozi
         AA4m8CQsp6a1UwhhJwj2Ibwup7hKODOaVncq135xA27yD7G1iW8vnUA5/n70GWzll0uC
         wvk8LeMwUz7/04ey9mo15ME1jKQaRCtxeHAnkPBOBXaFs09RlJSh+W+dI3dCVFgO2jcD
         6EPTDJYb4Vysxjr/0R9TUyIpX1CLT2/SInGBUfQrxA07/fwoFsQmU6XJXXy414iSs5s3
         ogiu/M49EOMavd71WS9iG0XSHG9cB6G4o5MiEYwrvtsWjDVR82OSEhukc1wnNYBmITck
         YeOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukecfI0GUmkgn1p78DSNU1ab3FDqFcXNt100ETt7p/0667J7hx8x
	pwL3FSUXOTxSkgqwTEpbt36ejkL2Fl91dY6R1omhXHGG72Z9EHpPfu6qmwL993cG0Jug5DGz5wn
	t0ZlKayhGlq9LH/kl17y22HgDydr2FXfxUQCdovXO6hj7/XPNFcFnMLqt4lKdUx28KA==
X-Received: by 2002:a0c:b527:: with SMTP id d39mr24695242qve.201.1548770896400;
        Tue, 29 Jan 2019 06:08:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5qMJvsiJ2sG8oF76fR8zQ+64Rl6CvXJWDnCtqUBjuVKzzxp6sG5qzww8Y4wjGWVDqvXqTk
X-Received: by 2002:a0c:b527:: with SMTP id d39mr24695186qve.201.1548770895694;
        Tue, 29 Jan 2019 06:08:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548770895; cv=none;
        d=google.com; s=arc-20160816;
        b=YhZNE17EQ3ZbXJZuNeOncFeTJhhJxsbsiMh/eebUyZl6JL6kSuKNyIfXdPRQMvw7kI
         4t0FphginAvKf7Yw6Ba3AqvU/vhMqY4doFKjQIUSaJ/LIwRRdqtR89tAAbd+CHZ0Nr8M
         puWFBRnGDdECDCws+zfI/SGBcgPAiriGWba1x5L6vbuW4GmIIT6Fl0fcM+Mu/zxwXS4K
         1kYncbfgy5NIGUD8zI10DFnMs01T0UhMWY7rLfFFpUvooBDfTmTjyItBKZjdrx/cEULk
         j3Yz5zN4KpQGyBrSYyD+/LP26tFyXJdOF1vX69aKdXzLgI6WS3xnWFtjZFajQoqwC3N6
         KL3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:mime-version:references
         :in-reply-to:subject:cc:to:from:date;
        bh=UH9CvHGKidG0zSad9i9agr3dX9d9QROln7gglTCOaQU=;
        b=eFL1i7PrI5wKF57qwfU5eXD1f5yfl+q7of31N4DCrWRhq8dxwpkjmz9vkUxX70nOfS
         0MS4Jli/g/u8pucz57NmlgchQcfAylyUoX0Am+ato/RIGXBAiLfJcVVnL9xcXHbJwMlz
         JmbaZPVnLS0QlYThlY1Q7sjtilfwbCjZhYZWciakTymuy2r5KcyoDdnCiul3gKlw6bdQ
         sUShnV/mBHedELcBbbznDvK7Ei2iIwMnEmyJ4jhfn6AWPt/49PY4LOgeh2RMt5Q7QBes
         hkcr5pOfEflpIokcDNr0NghnSqZZ259wWm6U2rwqmcgEwBJ6L5mdS41o+04gwbMJ6FN5
         tP2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m93si3466770qtd.270.2019.01.29.06.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 06:08:15 -0800 (PST)
Received-SPF: pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TE4VmC123074
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:08:15 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qaq8tv95j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:08:14 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 29 Jan 2019 14:08:13 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 14:08:10 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TE89WO9044292
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 14:08:09 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9D14A4054;
	Tue, 29 Jan 2019 14:08:09 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 77D93A405C;
	Tue, 29 Jan 2019 14:08:09 +0000 (GMT)
Received: from thinkpad (unknown [9.152.99.81])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 29 Jan 2019 14:08:09 +0000 (GMT)
Date: Tue, 29 Jan 2019 15:08:08 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
        Mikhail Gavrilov
 <mikhail.v.gavrilov@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, linux-mm@kvack.org,
        LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages
 fallouts.
In-Reply-To: <20190129134920.GM18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
	<20190129141447.34aa9d0c@thinkpad>
	<20190129134920.GM18811@dhcp22.suse.cz>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19012914-0028-0000-0000-000003405403
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012914-0029-0000-0000-000023FD56DF
Message-Id: <20190129150808.685d7d39@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290107
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 14:49:20 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 29-01-19 14:14:47, Gerald Schaefer wrote:
> > On Mon, 28 Jan 2019 15:45:04 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > Hi,
> > > Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> > > have pushed back on those fixes because I believed that it is much
> > > better to plug the problem at the initialization time rather than play
> > > whack-a-mole all over the hotplug code and find all the places which
> > > expect the full memory section to be initialized. We have ended up with
> > > 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> > > memory section") merged and cause a regression [2][3]. The reason is
> > > that there might be memory layouts when two NUMA nodes share the same
> > > memory section so the merged fix is simply incorrect.
> > > 
> > > In order to plug this hole we really have to be zone range aware in
> > > those handlers. I have split up the original patch into two. One is
> > > unchanged (patch 2) and I took a different approach for `removable'
> > > crash. It would be great if Mikhail could test it still works for his
> > > memory layout.
> > > 
> > > [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> > > [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> > > [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> > 
> > I verified that both patches fix the issues we had with valid_zones
> > (with mem=2050M) and removable (with mem=3075M).
> > 
> > However, the call trace in the description of your patch 1 is wrong.
> > You basically have the same call trace for test_pages_in_a_zone in
> > both patches. The "removable" patch should have the call trace for
> > is_mem_section_removable from Mikhails original patches:
> 
> Thanks for testing. Can I use you Tested-by?

Sure, forgot to add this:
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

> 
> >  CONFIG_DEBUG_VM_PGFLAGS=y
> >  kernel parameter mem=3075M
> >  --------------------------
> >  page:000003d08300c000 is uninitialized and poisoned
> >  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >  Call Trace:
> >  ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
> >   [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
> >   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> >   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> >   [<00000000003e4194>] seq_read+0x204/0x480
> >   [<00000000003b53ea>] __vfs_read+0x32/0x178
> >   [<00000000003b55b2>] vfs_read+0x82/0x138
> >   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> >   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> >  Last Breaking-Event-Address:
> >   [<000000000038596c>] is_mem_section_removable+0xb4/0x190
> >  Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> Yeah, this is c&p mistake on my end. I will use this trace instead.
> Thanks for spotting.

