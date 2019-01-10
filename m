Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3949C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 12:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67534214DA
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 12:37:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67534214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB96F8E009D; Thu, 10 Jan 2019 07:37:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E69AF8E0038; Thu, 10 Jan 2019 07:37:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D31298E009D; Thu, 10 Jan 2019 07:37:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A565D8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:37:13 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so9993065qtc.22
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:37:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=idE3oWkaJgXKNp0T7oyW6bgT5hObsaT6ydf+POpPD/o=;
        b=j3YzznRQ8RT+psl5cB0ebOqvN8QXMbtwcWfoTVzMSU2o5EV5HRl5/hcyzmoqEfoog7
         /5mFerQP2M1qtfP/lPMmbJJ34ybgDUxGhV1bkpfMnoIcAsFnCEtGFBq/5sQ03SAgCI1C
         Yyhk+pXQEOkxzD4kvmD0fAFodaPc/c3XxML7AORUIzMmpNkOE5D8eM9I5c+Rmu+/Oua+
         fJCLAoz4Y5LlNVeQkeV/9gD5RqULAYWJP5ESkfvzGl5t0Aa41Yv1Xbgyh/20qdRR3NEp
         GyrAr1e8caq1Iv6cmtHQfx9/iy1ug534iUb8wVCGvMo50l3RagMgFutKq2efgH+Jhuox
         eC2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfdCQyL5k26fa+LriirEU5Iqc0af6YGtllILC8IoLvRIgjXIzec
	CzVZMucR1xMS/FR0vve7sb6KwZnhU7umZEGE6NN9wzNaO4rmHEZMHEdnr/LB1xriKFca/VSNu/L
	O7QuoBxMvCMaka3naFnc8zrYgCFnQ5Dpc4oKd7h+UU5UKtemXa0hPXJAtYHbEs+sw3w==
X-Received: by 2002:a37:7e45:: with SMTP id z66mr8937906qkc.23.1547123833383;
        Thu, 10 Jan 2019 04:37:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5aqE73gG+LPD1YkDwtqEMTR5fZMZ/Zq3ZD+cBD/KrxNZdKFGBb4YYx4/fFmnbWQx6AC/ii
X-Received: by 2002:a37:7e45:: with SMTP id z66mr8937882qkc.23.1547123832854;
        Thu, 10 Jan 2019 04:37:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547123832; cv=none;
        d=google.com; s=arc-20160816;
        b=eRd8HmgoTeLw/Ryvzt0iOPy1YBFvl9lh/LKPY/d7VqDUEdl2ILYqW/Y8F02NwCAYti
         B1ORlUfpa4fl6G2POlNBPuAahpwuAykr44Bn+Oy4YE4Jr/vwh2mC39qZ8aNKntTftIK/
         5/f8MY4KgqSikPtIeI4kdTG18xffIeB9E1en3c6X9Vk4mJM7ZZyPH1Wk7n9XMgo32lC1
         la5dm6YiMkdVlEycANDs2SJl6x7CMSy9/Cs3ZN+Vn6xWPdxXPrmrVDr8zXt9dSQBfyn/
         +5iAvzCgm5EINq3Oo1WhPpKtA24Tbyri/g5C7opXWpI8ciNamfmXS6BzdqC8Bl1uwd+I
         eIrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=idE3oWkaJgXKNp0T7oyW6bgT5hObsaT6ydf+POpPD/o=;
        b=GmjGwShUjXhReAFABUOIKe0QzO0EShwjIQ5NxCqbTBN40H8LoIU2Z/wP9L+rgJVL7l
         bkRyhgFo85m6wIpiaGRUPB2FxgGtr9l9D17w1j6qxq+jf6gEwFgHyZ2hVhg9HVyM9SOr
         IJcc66qafGda7azQ32NxQJSN+Ki0j5ruH5B6CVkU7IV2dsC/ZPkZ7IOxlK8xUgtIV785
         cylzspcl7WS9DjvPdXjfGce99b+l7Mb89pvsf6IkNlNF4VIn3AYpsfAJgdH+gfFr6NZK
         ykmkuumKs0vh9CG1F39uLHDkwP4E1cvbdWmyJ+0hBE47Zv1Mcd20dSYFn3tiu4ID+0Ty
         uPCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l91si375939qtd.76.2019.01.10.04.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 04:37:12 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0ACYqqE127403
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:37:12 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2px5j7hv1b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:37:12 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 10 Jan 2019 12:37:10 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 10 Jan 2019 12:37:07 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0ACb6Wo65536032
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 10 Jan 2019 12:37:06 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 50927A405F;
	Thu, 10 Jan 2019 12:37:06 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4ABB0A405B;
	Thu, 10 Jan 2019 12:37:04 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.54.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 10 Jan 2019 12:37:04 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
        linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Rafael Wysocki <rafael@kernel.org>,
        Dave Hansen <dave.hansen@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
In-Reply-To: <20190109174341.19818-8-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-8-keith.busch@intel.com>
Date: Thu, 10 Jan 2019 18:07:02 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-AS-GCONF: 00
x-cbid: 19011012-0020-0000-0000-000003045E6F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19011012-0021-0000-0000-0000215561FA
Message-Id: <87y37sit8x.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-10_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901100103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110123702.Rd-LFDsvnvcMcR-_5BZMLo_R7ymgeUAT79CnR0m4CT4@z>

Keith Busch <keith.busch@intel.com> writes:

> Heterogeneous memory systems provide memory nodes with different latency
> and bandwidth performance attributes. Provide a new kernel interface for
> subsystems to register the attributes under the memory target node's
> initiator access class. If the system provides this information, applications
> may query these attributes when deciding which node to request memory.
>
> The following example shows the new sysfs hierarchy for a node exporting
> performance attributes:
>
>   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
>   /sys/devices/system/node/nodeY/classZ/
>   |-- read_bandwidth
>   |-- read_latency
>   |-- write_bandwidth
>   `-- write_latency
>
> The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> Memory accesses from an initiator node that is not one of the memory's
> class "Z" initiator nodes may encounter different performance than
> reported here. When a subsystem makes use of this interface, initiators
> of a lower class number, "Z", have better performance relative to higher
> class numbers. When provided, class 0 is the highest performing access
> class.

How does the definition of performance relate to bandwidth and latency here?. The
initiator in this class has the least latency and high bandwidth? Can there
be a scenario where both are not best for the same node? ie, for a
target Node Y, initiator Node A gives the highest bandwidth but initiator
Node B gets the least latency. How such a config can be represented? Or is
that not possible?

-aneesh

