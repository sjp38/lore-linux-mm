Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B8FDC282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19B03222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:27:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4uhNkb1F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19B03222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D8DA8E0002; Tue, 12 Feb 2019 19:27:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 988458E0001; Tue, 12 Feb 2019 19:27:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8768E8E0002; Tue, 12 Feb 2019 19:27:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFDA8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:27:04 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 135so1100989itk.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:27:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=w0tqhPo+t2SUjHi0LS/CYN1wUpJy7dXBRCRCEWoqsoM=;
        b=YxYeTHZVtw3EQlEfVp5p0D1D4LVkVSV0KcZR8ABOlenZDFJJRQekccof7O/Qdr4tN4
         UdM7j/rHttc1abQmM/7CW0U2gpcGgJcRZAxR2rtGZParzLUxE60AKfIUfEOdf2bTpoja
         wPjjas+aJe9BCiWI94ARDq5EN9GAJAo2lawkVE69LrVlUSn8Wp6YYD+MHMXEKNeMGCDT
         2xMsjXkt2kKlJEPQEbB2L1QJTd6GeBN1KZlOv1Bo5c9CRvtdLBP+EennjV52hfr7g6X4
         xij/ERhIxQNhijhaKhD6C84oESqLqauXzJEHii7TGbPNAc0zBBIL5QGgIRaV4/qqsN+D
         cVFw==
X-Gm-Message-State: AHQUAubQsydml26cJW1J4Jy8q5UMOaIWJ/mpHuq1stHINUwg0Hik0BTF
	7Eu/eexzbkKYDvqjnX8pCjFTPw72FfyvMSpBFK/m3pkBJv/cAwpXK2716Mz9OldqO35mobPBjOi
	kEXP0aKFb2f412nSFr6ABkDCxHBuSMNJRY38mm7SebOSGb8PRKgDylqCZWEndC7f9ww==
X-Received: by 2002:a5d:9508:: with SMTP id d8mr4125575iom.155.1550017624157;
        Tue, 12 Feb 2019 16:27:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIYIkrnLmz0538dy1nmXCqz+hquU7YTH44sPPflLZ+v3wtwB9uCyArt3SWlkaB/38zuDny
X-Received: by 2002:a5d:9508:: with SMTP id d8mr4125555iom.155.1550017623581;
        Tue, 12 Feb 2019 16:27:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550017623; cv=none;
        d=google.com; s=arc-20160816;
        b=F6So8KBVPmQhbWI0pWsFrA9lGQrx5QEOQTzvlacnmwf8ScJpBt+2UDcCrwdtEoMEZD
         ZELeknQXorQxyRs2bStxEDHQ12nD/AiexlUzG7vOsXxiOoUWHhXt4TEhnyMzETcPPnOX
         ufQ0KEoG/0/2NrWhxeKzeYpuRRlctu+0NKpb61goL0bh5PJwXTiZxFgrwUUzA5kY02oZ
         eeutG6coCuhzpqhrPcOFyfCJ6oL+dz9LwP3qim7gNJAtGDYjJmbubdsZahdwgKrZzL4n
         loXCPF/rTJzTa09LHHq/dLDIptRmue5afdmznZJj2poTGePqnYrAXQedLUACDUo9Xiy+
         HLFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=w0tqhPo+t2SUjHi0LS/CYN1wUpJy7dXBRCRCEWoqsoM=;
        b=DRNDfyL2b81w3jEr035CgP6lXvuoeBZM0NtU0xvB3z5Xn9gIpS6glToOYI2W2AdzQR
         XPkC0a2dRXJHzwJ8AaIsimzF2F1bUA/lLIrOxqrxTPw9iDzk/lIHwk+CkBqvO/LNj1ac
         TD+Weak0dagEj++p5Cwr1qIcydJWnXwotO/aHl/JelMrJ9J9f10ic1xb/1+6ALKVgBpq
         MN6ZcE7vOx0roIxVxpc+OkhO4lNNgq30GLjYuaxzwjSY1lU5B/CdNPjJlH66oO0BeaNJ
         A5HUA2ZJblLxMxa0bV+sfMHHCrVIxZztmjr7wRZ9E5FYIe33Kg66rNd85AcLsovhlqXi
         K7eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4uhNkb1F;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x67si2133191itd.31.2019.02.12.16.27.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 16:27:03 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4uhNkb1F;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1D04ItA127795;
	Wed, 13 Feb 2019 00:26:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=w0tqhPo+t2SUjHi0LS/CYN1wUpJy7dXBRCRCEWoqsoM=;
 b=4uhNkb1FBNWMTFMQtPUk8damVBnjRIUT7GL5gQsYHz64WDzTPPtvcus+e60ProDyirXA
 BIBzWsGcRc0nHdUKObIy7isnuU5mxDmG2Eqhgwswz9l/zeQmVrqvv1bmjZ8tNlW73vQ3
 tIV/bA4IIkByvi7kHkDTFv1HTComQfdsds3sPIbvf/J7/+e7CJkeuo+0gzdHgxyxhTqs
 gOh37VPD3tZ18pYTYvOcFEO/9Q8Z+mwAyAeGdutNQ7Rt8uWL2gmrFHP2efApacziCexv
 WvNERa0JSl/O7luXzRpjaQdoxFvecYasxSh7RwfvLmZctY10vmFVu2Tyzquis+f2PhaC gQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qhre5f4r3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 00:26:36 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1D0QYY2005778
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 00:26:34 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1D0QUic020233;
	Wed, 13 Feb 2019 00:26:31 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 16:26:30 -0800
Date: Tue, 12 Feb 2019 19:26:50 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz,
        cl@linux.com, linux-mm@kvack.org, kvm@vger.kernel.org,
        kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        peterz@infradead.org
Subject: Re: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to
 account pinned pages
Message-ID: <20190213002650.kav7xc4r2xs5f3ef@ca-dmjordan1.us.oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-2-daniel.m.jordan@oracle.com>
 <20190211225620.GO24692@ziepe.ca>
 <20190211231152.qflff6g2asmkb6hr@ca-dmjordan1.us.oracle.com>
 <20190212114110.17bc8a14@w520.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212114110.17bc8a14@w520.home>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:41:10AM -0700, Alex Williamson wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> > On Mon, Feb 11, 2019 at 03:56:20PM -0700, Jason Gunthorpe wrote:
> > > I haven't looked at this super closely, but how does this stuff work?
> > > 
> > > do_mlock doesn't touch pinned_vm, and this doesn't touch locked_vm...
> > > 
> > > Shouldn't all this be 'if (locked_vm + pinned_vm < RLIMIT_MEMLOCK)' ?
> > >
> > > Otherwise MEMLOCK is really doubled..  
> > 
> > So this has been a problem for some time, but it's not as easy as adding them
> > together, see [1][2] for a start.
> > 
> > The locked_vm/pinned_vm issue definitely needs fixing, but all this series is
> > trying to do is account to the right counter.

Thanks for taking a look, Alex.

> This still makes me nervous because we have userspace dependencies on
> setting process locked memory.

Could you please expand on this?  Trying to get more context.

> There's a user visible difference if we
> account for them in the same bucket vs separate.  Perhaps we're
> counting in the wrong bucket now, but if we "fix" that and userspace
> adapts, how do we ever go back to accounting both mlocked and pinned
> memory combined against rlimit?  Thanks,

PeterZ posted an RFC that addresses this point[1].  It kept pinned_vm and
locked_vm accounting separate, but allowed the two to be added safely to be
compared against RLIMIT_MEMLOCK.

Anyway, until some solution is agreed on, are there objections to converting
locked_vm to an atomic, to avoid user-visible changes, instead of switching
locked_vm users to pinned_vm?

Daniel

[1] http://lkml.kernel.org/r/20130524140114.GK23650@twins.programming.kicks-ass.net

