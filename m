Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7851BC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:31:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AAFF20862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:31:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uWWnZxvM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AAFF20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9A7C6B0003; Wed, 15 May 2019 11:31:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B24496B0006; Wed, 15 May 2019 11:31:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C4786B0007; Wed, 15 May 2019 11:31:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7801E6B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:31:07 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id l193so327216ita.8
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:31:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BdPtnDR11Vdn7XWeNGSG6wyyu26x7E5yMudl0+Igi6Y=;
        b=e1Rsmr5m0zyFpCE79VKidGJuustkhE7xtwt5OF1bFyqtqXkN9a823uCYmfQ0BGfrnQ
         RYsW/hk/zf53JtRJZlESgwKVziDL5wjnXZhnzipJ9LsvNdRqvAKlRwRa1d9m6O2r6AJL
         owekAtOSwbcGNWxSV0nr7VKxjXZeSex9YgSfkP0I/rDEQb+X9cLH1t2cpM0kcg4aeZBa
         3+aI5xCzF5L0B9eFcokSIxuBMdmpqIUqHYUqeM6k3xElj/v4CD8Con+kvheu7vqNNMFK
         LpnTF/eO5hAM+RYIzUkugAj0Cpz5d38K6H/PiaOm/H6/SUbh1HdxeUcFEsx2U9MHmH0e
         6jBg==
X-Gm-Message-State: APjAAAXgDj2gNaJ2jnwwSrngdCGs29tUIW5DlW+HOJVrNb6wFF5JsXJr
	6RlBjOegxUZFLc3U7+28+ksEdoBV4W0C0Vx15nyt9jiqFIg8lPwWHyMz3IWLUDhN9WTh1xm97uk
	rwvF+W1bWlrRfFY2Gh0XEBRZYxhTeCVTElhzbt86zarIyXw4JBY3hGuvY9QLkgjgRBQ==
X-Received: by 2002:a02:b1cd:: with SMTP id u13mr27696642jah.60.1557934267201;
        Wed, 15 May 2019 08:31:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6to6y3j740UXTdOSlMhYaVIsdaPXaznR5r23Q8lUNSr+vvUX4UzDxJiww79Yu2w+EaAYR
X-Received: by 2002:a02:b1cd:: with SMTP id u13mr27696590jah.60.1557934266428;
        Wed, 15 May 2019 08:31:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557934266; cv=none;
        d=google.com; s=arc-20160816;
        b=TyAVt2bsKOVZxYOFc9BG2GlI0E8Xb+QSJp44cuKTEcBYomlO/IkA2Vm4ABvWIP+o+/
         FPLoZBszjNiUdPO38dOzGF9IEZs9qXeuz1KzYDBy+FF1w0ADBD8ZHj0BjC3XsMgU1fMr
         puQx287NSKUJmVEBeUtVhBjXAmfifY1QsNSadLb9spWqWqnYXpTukZHe+JcgRnCacopF
         UqVsLtpoCmeaf0nH1SVLp7SCMKkYe6IapYFV1YvEr3mHXZKRWZvnhm/Yby4BEO3p0EOE
         5kxytPl/QMgx8EJ/zgU6luqYZXiJ33FGnXNB7qrH12PQlgTMIDCxAVb+/GaH/T/sURPN
         8HBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BdPtnDR11Vdn7XWeNGSG6wyyu26x7E5yMudl0+Igi6Y=;
        b=kNclQClPCnz3XQ+OH7pJVQXv/Uss5p8GxKCbD5Vo0AVf3WAo+7FV/mXj1c6sgDvsgs
         wMwzcInwyXo7KcZMaIDkoK3jISX0hEBGrh2E5860GUSJqKImuoA9Sg1g+etr1a5u2K9s
         o4DLaYzUxhEzqaDHBojNXui72Ktgh/z8XkRh037HWvY8jyMV9fSNNrOBo1gul5Sm1up2
         Khp8/GDZBPMiZk9E6uL6IXrqsTyogbIZ9O7u4Bw1GIZ0oIhb5fYG5UcTrIPurC61QQdB
         3JdU8cancJ26uvVW1OMqZF/3+8PA8dDcXMrD44pRIZa3ljs/cf5IB4bQ1Jd7kszSyNlM
         YJgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uWWnZxvM;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p197si1543156jap.20.2019.05.15.08.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:31:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uWWnZxvM;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FFNsAX013479;
	Wed, 15 May 2019 15:31:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=BdPtnDR11Vdn7XWeNGSG6wyyu26x7E5yMudl0+Igi6Y=;
 b=uWWnZxvML88GDB2B0uUzOE8auo8d+Kcumm+yrje6UE4Io8lI4TzL64qQi9UaCu7LKHh9
 mmdesnwP0yVIdC38FHD1l3lgcXIxoxpkD3TlNEAgG5wY9zjeRkdva9ipeNaEmZR3ns5k
 hSQNSiNi9KNrPBUcHjXxcQEZzCHsLxVdhTA7PQHAnKbfxAy9a2nyuu+T28HTLfqBBHdd
 xZnwUVFMakHOPllfGxS4wkzapMc51X8c/nZVIqsYtie+2ksPEaTsFeWTszM4VqGs+AiD
 j+QKUOAfaCM9kSGPmxHAlKRdmEmRsXbwysXN/Sl/RWEDtN8h28+Rzt3wkYwjQLs3FZbb 8g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdnttwnuf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 15:31:04 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FFTMHe069829;
	Wed, 15 May 2019 15:31:03 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2sgk76jtdw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 15:31:03 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4FFV1mJ022122;
	Wed, 15 May 2019 15:31:02 GMT
Received: from lap1 (/77.138.183.59)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 15 May 2019 08:31:01 -0700
Date: Wed, 15 May 2019 18:30:51 +0300
From: Yuval Shaia <yuval.shaia@oracle.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: RDMA mailing list <linux-rdma@vger.kernel.org>,
        linux-netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
        Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190515153050.GB2356@lap1>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514122321.GH6425@mtr-leonro.mtl.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905150095
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905150095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
> This is a call for proposals for the 4th RDMA mini-summit at the Linux
> Plumbers Conference in Lisbon, Portugal, which will be happening on
> September 9-11h, 2019.
> 
> We are looking for topics with focus on active audience discussions
> and problem solving. The preferable topic is up to 30 minutes with
> 3-5 slides maximum.

Abstract: Expand the virtio portfolio with RDMA 

Description:
Data center backends use more and more RDMA or RoCE devices and more and
more software runs in virtualized environment.
There is a need for a standard to enable RDMA/RoCE on Virtual Machines.
Virtio is the optimal solution since is the de-facto para-virtualizaton
technology and also because the Virtio specification allows Hardware
Vendors to support Virtio protocol natively in order to achieve bare metal
performance.
This talk addresses challenges in defining the RDMA/RoCE Virtio
Specification and a look forward on possible implementation techniques.

> 
> This year, the LPC will include netdev track too and it is
> collocated with Kernel Summit, such timing makes an excellent
> opportunity to drive cross-tree solutions.
> 
> BTW, RDMA is not accepted yet as a track in LPC, but let's think
> positive and start collect topics.
> 
> Thanks

