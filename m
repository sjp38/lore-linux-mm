Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6636FC072AD
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AC8D21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:00:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AC8D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374696B0007; Tue, 21 May 2019 12:00:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FFB36B0008; Tue, 21 May 2019 12:00:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 151246B000A; Tue, 21 May 2019 12:00:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0E586B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:00:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m12so11633661pls.10
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:00:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Agwbv2xYoj93ShP9YQ91ZTFTUjkpUahc5IP7vbLxDVQ=;
        b=OCihRXeBVLCq7TVFV1oUyaWI7t2UmbsukOCODd27zkOjPb7O96+jD3nagpkJazkul6
         A1MenhYDa+tcrrYVqCxYAMIDK/cDvvQNG30JbsozkiM6pDvzMdpvcO55B2wnI8e2FqOm
         4lhCrt0llJ1gygTvJxxGCCEA+EetrCrv9wYRcHKfJvWecpkKKxoe6ByySDT52Q3ZDYcH
         2kJfXU2+IiP8DCt8D45X1BOkRhnfsT4nk+V9lxsi4+EcyRsQo4nSL2lpKEIomKbmY+cT
         2qOlSh+Vy+vaLywcMlx1T6Zs/8/gmbyu47/DthLCXEK7G20J0zsfIralAJUXZmGc7FEB
         C3pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXj/DPfWzklwbKIDOJpfcpTVXpDrfD2ZKtPbxPaltbGwyd/1HzA
	JbRI4c0P7HP3KEthaygXtoSxtjVI2kJE9Qw24eQ2BSWspk9YM3kZ4tNVqdv6xUDB0TTudjl3phg
	3N2OWhykiXnUYG5hEIReLwgQyWMT7TioKbYJoLgWU2wTUrbepADGpIGdE3m9QmXPMiQ==
X-Received: by 2002:a63:1061:: with SMTP id 33mr56824928pgq.328.1558454450482;
        Tue, 21 May 2019 09:00:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw+HLkytFub/PTPbrw04iGKJR+23iHUN5NbgXLayFqd0Rwe3/vLJa6+QGlRprHWR6LBzkm
X-Received: by 2002:a63:1061:: with SMTP id 33mr56824824pgq.328.1558454449765;
        Tue, 21 May 2019 09:00:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454449; cv=none;
        d=google.com; s=arc-20160816;
        b=ZlYwTeNp/Zbwr+ei2GkOJ6etTnk5G5C4vLYRVTrtNQ9iNqu3S8LrGvxvnSDeYxKPld
         LlALnWnt0ToNJyou+Ae3l9erJiZClY44rwMMam9nuup++AncLhtYc2OkTr1/e4ZEMTFN
         +ZSU1GE47Zi3Pa2d/IiFTFRaSTAxeVrfFNLdxs4lJZsJx3kCwBk6pGR0occS8uw+5Q7W
         A8fghtMRxDar17x53qlhiMK1TfN2sOuVTcW+EoQ6+eJlDNoDyrc3hYy3yayoEPztaQHb
         B1spSxeMM57Pn+Ocs+ed8R1KexT4L2kdC2jwr1Q8HKsVaxRB53ertmV1wqkm404VhAIS
         Z98w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Agwbv2xYoj93ShP9YQ91ZTFTUjkpUahc5IP7vbLxDVQ=;
        b=vKlMXPg/dMoWk+f8v+bIDmgYN63lBJUL6Wr4Zb/+74E6JjUtMD82b/svnQa7sSz1L7
         xT0hd/P49hZzmZV3vlJnaqCwmHWAlcLBWH09j69k0kJgyeeM29bU9xK5CY9F+bi14kZV
         PS1IfgkjrI59hNCxow7R4Qx3Yxm0kgpNlFWqJFypYQkXFR/UXYCufTxRlpmNKFqD3K78
         +UhDew3QMQicJki8VqBMWw1a2QJUvcd4gTP9BbOKx3mpP/4dAI0eUmYElQDBPPCivtRM
         yb+AP5kWWusARvTzFp35x+sU7lkA/+k1oU2g8nTCf83fvBR0vZQVHOMLDQlzrL3zMwYC
         E4JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m14si16706569pls.393.2019.05.21.09.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:00:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LFraPg121867
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:00:49 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2smkf3b109-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:00:48 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 21 May 2019 17:00:46 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 21 May 2019 17:00:44 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4LG0hix18546822
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 16:00:43 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 44A96A4068;
	Tue, 21 May 2019 16:00:43 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A727BA4066;
	Tue, 21 May 2019 16:00:42 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.239])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 21 May 2019 16:00:42 +0000 (GMT)
Date: Tue, 21 May 2019 19:00:40 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: David Hildenbrand <david@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs: reorder memory-hotplug documentation
References: <1557822213-19058-1-git-send-email-rppt@linux.ibm.com>
 <43092504-a95f-374d-f3db-b961dd8ac428@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43092504-a95f-374d-f3db-b961dd8ac428@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052116-0028-0000-0000-000003700856
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052116-0029-0000-0000-0000242FB33F
Message-Id: <20190521160040.GE24470@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=815 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:41:50PM +0200, David Hildenbrand wrote:
> On 14.05.19 10:23, Mike Rapoport wrote:
> > The "Locking Internals" section of the memory-hotplug documentation is
> > duplicated in admin-guide and core-api. Drop the admin-guide copy as
> > locking internals does not belong there.
> > 
> > While on it, move the "Future Work" section to the core-api part.
> 
> Looks sane, but the future work part is really outdated, can we remove
> this completely?
> 
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> > +
> > +Future Work
> > +===========
> > +
> > +  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
> > +    sysctl or new control file.
> 
> ... that already works if I am not completely missing the point here
> 
> > +  - showing memory block and physical device relationship.
> 
> ... that is available for s390x only AFAIK
> 
> > +  - test and make it better memory offlining.
> 
> ... no big news ;)
> 
> > +  - support HugeTLB page migration and offlining.
> 
> ... I remember that Oscar was doing something in that area, Oscar?
> 
> > +  - memmap removing at memory offline.
> 
> ... no, we don't want this. However, we should properly clean up zone
> information when offlining
> 
> > +  - physical remove memory.
> 
> ... I don't even understand what that means.
> 
> 
> I'd vote for removing the future work part, this is pretty outdated.
 
Frankly, I haven't looked at the details, just simply moved the text over.
I don't mind sending another mechanical patch that removes the future work
part.

But it would be far better if somebody who's actively working on memory
hotplug would replace it with a description how this actually works ;-)
 
> -- 
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Sincerely yours,
Mike.

