Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 684C9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 11:19:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A13121841
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 11:19:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WzV3YhX7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A13121841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96D106B0003; Thu, 21 Mar 2019 07:19:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F4066B0006; Thu, 21 Mar 2019 07:19:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BCC66B0007; Thu, 21 Mar 2019 07:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D83C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:19:38 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id h3so7322348ywe.21
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 04:19:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=+CJEDJDV8tQlaLOEq1gYhqwy9hEc1BIFmium5TeXdTU=;
        b=FjKh6LhZlxzM5jMukPJee3UXQ/sejn31YghTxZT0CTjmAVgHl9uL/usc62kV+c14Ne
         yzxdWNMtnR5FTgcslIYTkyNufIlm6sdmD9QcEjneEaQU2+jB8kBPk9WSTSUmze9G7ciA
         3QIttke0RVwIVCYBAa/w2XX4XLMgMCszeyGG7P6gQrUMRpC/Q2UQmxqk29Noe5+sY/l3
         JM/flfgPh8kw7EykNOAZL7Nd3y6jNrMqIToOBpDVp0q3PFSHJXbiLjLYT5EAFjFTz8ZR
         0kG+jmYei69rmkKJhkprqwgXMQmSYDGuK2FLgsJmCB2UMz9Cnbp1V6B3k55Xjr4hPvOh
         SnVA==
X-Gm-Message-State: APjAAAWM8N2YLHTtNstw5Yi8ebTUb/FaQWj8dEQMVfR2P6FEmbzZGiYG
	DNo4eD3/LtxIJ1H9mijMOCTNIBuYgiycNRwZiYyDdIRoEDjixec75gVWalmufPd+Ixs5xwHHRAS
	37WqGKu2bJXshj8M2/xBk65aVPBygG3nIIqn9V0mB5cdymqzJeINHXPVdtKUprbZ1lw==
X-Received: by 2002:a81:7b46:: with SMTP id w67mr2520394ywc.45.1553167178023;
        Thu, 21 Mar 2019 04:19:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4ez2lhqqjc/OvMIqmyTQKMWoshRoAsiAMF4uhzmcj8WZCLxjkNmLUevCbZ2CdTF7irc2O
X-Received: by 2002:a81:7b46:: with SMTP id w67mr2520356ywc.45.1553167177362;
        Thu, 21 Mar 2019 04:19:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553167177; cv=none;
        d=google.com; s=arc-20160816;
        b=QHM2vC3neXY/IA/BoY6CtNVZg1L1dG1yaSeBORg6luYIUiJUex4PJEodJvOVa6qnA/
         pdEkFODO66CXW46c1rSsJx2GQSyPqlIxMP88k5qWUIJYTC6TftABnRec7XM5PrkpVpNK
         URPqzUMd5xc5C8Ai02ZydS5wBtBpoLV3R5uJLDQxyLtEwsrYIa5v7tJYiYCAKHzzFWcl
         0gEKXsDGMQ9EexVu4M65jFO/aHFVdJSGYz9P55+iDS7VsDypnvT6brojToM9Fp6qHwjN
         OQgviu8m5iqbp7QwQVANfKj9K0KmyOQVM49/WXV6og3aR3RMo55FLFFUkB4J3eAohUyo
         WP5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=+CJEDJDV8tQlaLOEq1gYhqwy9hEc1BIFmium5TeXdTU=;
        b=MSco3ruMjE/NDxogMfPAiS0sKbcBYInIVfscpF3TK8fU+5LA+0SxSFPoT6Wb5Zf8yX
         8TGAzwwzoCnKnqLu8QS5HBx+1sNDTmxEIrIf62jxe+3No01ZZOX3E90pPhMmxMyGOeeM
         w7e/XmqHaQsPHtXX8ioVCmbXi42p/aUEmGwhVpZO8l/dEKiqS/fG1usNJtEbSiPtXpw5
         tXzif+xk9yf1DtnYFiiI56UmqQTC9Uc6/BsLK8N/6GRpFfNfxDSIzpm8vmjOo07oroa1
         xAxrwymcIcIJE5zgBmsJeaTYBAS5P8HGZRGnacHfMxVfC8yCnh3lTVHdv3YB5BVMGdRk
         GqbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WzV3YhX7;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o133si2932182ybg.321.2019.03.21.04.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 04:19:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WzV3YhX7;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2LB4PG2011912;
	Thu, 21 Mar 2019 11:19:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=+CJEDJDV8tQlaLOEq1gYhqwy9hEc1BIFmium5TeXdTU=;
 b=WzV3YhX7GTERYIllfGWH0lMhUu7JlfzZ2vIPq9XtmOf2nZCzAElC7c0C4fiGw5wiqhaK
 mUYCycxVnvbM3PygFseVblhmnDSFTb9gydljjwLqUvSGWzEvs4SdD2Vc3ynF8+2BlG+L
 WwJ6xdGL72PBJsoSYKb+DwNHBX2SFtYEf1zsx9migKCRf5A7MlUJ6kMH89nNraGhL8ja
 yC0JLNrmM92JsnLjb5mQFJIqyCBXDCqHSDjXSqizGIIW5EI8HlR5xcA3OPufohxKKQWo
 2m6dhOs3rwoEYX7bc5l+7ybTg7/UvGgdGg92onAB3a3/X89Gz0amBXEUCerEB+LNQZpT BQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2r8rjuyvam-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 11:19:28 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2LBJNFG003439
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 11:19:23 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2LBJLEd007773;
	Thu, 21 Mar 2019 11:19:21 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 21 Mar 2019 04:19:21 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190321103521.GO8696@dhcp22.suse.cz>
Date: Thu, 21 Mar 2019 05:19:19 -0600
Cc: Baoquan He <bhe@redhat.com>, Matthew Wilcox <willy@infradead.org>,
        Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>, rppt@linux.vnet.ibm.com,
        richard.weiyang@gmail.com, linux-mm@kvack.org
Content-Transfer-Encoding: 7bit
Message-Id: <EAFD8223-BEED-4985-8CD4-D3410A5898A6@oracle.com>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
 <20190321064029.GW18740@MiWiFi-R3L-srv>
 <20190321092138.GY18740@MiWiFi-R3L-srv>
 <3FFF0A5F-AD27-4F31-8ECF-3B72135CF560@oracle.com>
 <20190321103521.GO8696@dhcp22.suse.cz>
To: Michal Hocko <mhocko@kernel.org>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9201 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=764 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903210082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 21, 2019, at 4:35 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> I am sorry to be snarky but hasn't this generated way much more email
> traffic than it really deserves? A simply and trivial clean up in the
> beginning that was it, right?

That's rather the point; that it did generate a fair amount of email
traffic indicates it's worthy of at least a passing mention in a
comment somewhere.

