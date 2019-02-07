Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E925C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF15021916
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OumiwyWk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF15021916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A30F48E0048; Thu,  7 Feb 2019 11:36:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D8078E0002; Thu,  7 Feb 2019 11:36:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA0F8E0048; Thu,  7 Feb 2019 11:36:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE538E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:36:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so311651pfo.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:36:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=aZ+aUDdPQcdjQqam9OtBRXqMLRv7aniMvESPb0JxeRE=;
        b=dYxmRN+zOpIWi/l9bSUI4bED94c5J2clUknc9MRsfHo8WFHE5KC4L2PguumsNc26sT
         SYhLgadZgRI6NFB+z/MYSaJoilyK5QQW876FlOTmm7SUayVDabtoJAzBuNzpja92CtkH
         w8DgRbl97v8LeOOxTZb44Md9d9eujWbeixRHQpJK5x/6JPTcvPVHpi9vdVctq0nKctsc
         C0gXXwow7qWx2DSODZFeMXUHtiJ+1tGh4SUjcffudp14JLOMNTJLDWI/m3LPkUSm7Qkc
         GMfnhtsi30aJSpBCk8b3/HN4nt6VZzqsFpxUk/nKeqZ4qAYUpqqYAuSU8lqinIUPSAqG
         jyjQ==
X-Gm-Message-State: AHQUAualYC7Ofsv8vkC/mqpamFDVZ575DsD+SsLuF2BMsXvQUH+g+kqC
	dmHn+wuEslBXoKP7XROL35dSZSkAMsI0Sncna4+4KIvhe2Uco7VoS7HznfhFMTtYj4o82pfEzf4
	H4Fot1yLkRwf9vo5uF46q44BbcEdbE/CsSweVJebXckc9XBsRMMEWnW7qfVCvov2ccA==
X-Received: by 2002:a63:fd07:: with SMTP id d7mr335205pgh.163.1549557371810;
        Thu, 07 Feb 2019 08:36:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZp6/R4nCdWhhyugynpFbYYJTqmtgakVSWmHU//nDE/JGohQAtrBPMmqIaZ++pGYOQkKWWL
X-Received: by 2002:a63:fd07:: with SMTP id d7mr4862052pgh.163.1549551913253;
        Thu, 07 Feb 2019 07:05:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549551913; cv=none;
        d=google.com; s=arc-20160816;
        b=aVIsrPjyNRFSnsQqzFNMjvrjdWsu8nHMIrgblVUj8YpaOg41NEoylPLxvnfTXRvh7t
         FS2F5I9NCRpMHiJUuDgW0o1yvCMsD0BVW+VgLbQ8bezigSqXPVIwSSnZ4ZfmmWzU/ArO
         kLSGY0Fzk0lWKzEcxB7opC95SuHyUjG6QfEGRWz0qGWGmTV5DuMseubDM/UtyAW5zrNQ
         b73QJ9mXN90DKZjG/a61D0ZtffuFcsPHenk2ANnGeeIueIWlWA6ui9nMJsrvhGDT8vil
         mGCBoxG0rzyqCbMoPDY5pzUMXwl3c5fQxGFfrXIoR2yw0R21ixOSse4ObD/Z+xijhcKk
         ij5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=aZ+aUDdPQcdjQqam9OtBRXqMLRv7aniMvESPb0JxeRE=;
        b=Gs5tr9nOlXGSAwkU5r7/Zsc7lHbDY/0+9M05i6BGXPnHWJ7H6y0PIJH3arhEOPf2NC
         in145XesBVbJhXWVph/tNnloWVRWGXG5ScDyF2yMMPJUfuXfDdYW2egNjkoTGE/gtTgM
         WFbUT2yuAhen64Iyl2LexUoAzeM10jyxe8fIVjpkK2Bh2cSD8MsgyNPIG7yji+8Xaxhc
         OKiOSNjXVEIA16SGLIJpFB4jvQiqDEf4Qq9aEwbWsJsAufBlPblbHe9w4QIVgHdp00c1
         iRdVtBdrL+Ut66hN5Yuz0vX6VgSJIkWGtyLowariykw6Wvw1+VkH5Tl/GyQVr0KFN2aA
         LMww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OumiwyWk;
       spf=pass (google.com: domain of chuck.lever@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=chuck.lever@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d30si9362409pla.74.2019.02.07.07.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:05:13 -0800 (PST)
Received-SPF: pass (google.com: domain of chuck.lever@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OumiwyWk;
       spf=pass (google.com: domain of chuck.lever@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=chuck.lever@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x17ExTYL013909;
	Thu, 7 Feb 2019 15:05:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=aZ+aUDdPQcdjQqam9OtBRXqMLRv7aniMvESPb0JxeRE=;
 b=OumiwyWkEOjkb9CQUVsK7I6JwGePiZ3pZsasA8CSeXuSMSNdaURbNEflNhFfKtEWlNbo
 MXcs//uc0lS3k0ZRZCOANJESSIyBzDG0yRfblq9VmXtPBXu5ZgSeqP8ZMJUdrOtPNYbg
 6I8uUEwWcyAvAqmVHvpFje2v/fQoJjQ0ADD4IGUabGU6wQXTRz6py0jFFi9Rrhus56H2
 m5SYluTjj4BqVT7lEDg3TDxI+ekZlx3nYVtOJNK/bkoTWxnjBWlx4KG+4y92fjax56X2
 nfAh5PplqNjsRmwNBYd3MnMv16Khvdvwql+KkCb8dxN403r8cSNisXxIT4v4YeHNQZJr TA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qd98nfe0w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 07 Feb 2019 15:05:01 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x17F4xCX006779
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 7 Feb 2019 15:05:00 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x17F4wSl007837;
	Thu, 7 Feb 2019 15:04:58 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 07 Feb 2019 15:04:58 +0000
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190207052310.GA22726@ziepe.ca>
Date: Thu, 7 Feb 2019 10:04:55 -0500
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
        Christopher Lameter <cl@linux.com>,
        Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
        Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
        linux-rdma <linux-rdma@vger.kernel.org>, linux-mm@kvack.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Michal Hocko <mhocko@kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
To: Jason Gunthorpe <jgg@ziepe.ca>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9159 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=774 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902070116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 7, 2019, at 12:23 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> 
> On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> 
>> Requiring ODP capable hardware and applications that control RDMA
>> access to use file leases and be able to cancel/recall client side
>> delegations (like NFS is already able to do!) seems like a pretty
> 
> So, what happens on NFS if the revoke takes too long?

NFS distinguishes between "recall" and "revoke". Dave used "recall"
here, it means that the server recalls the client's delegation. If
the client doesn't respond, the server revokes the delegation
unilaterally and other users are allowed to proceed.


--
Chuck Lever



