Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA10C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:15:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C22BB20815
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:15:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aW6+HG7z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C22BB20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 468086B0006; Wed, 15 May 2019 14:15:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1C16B0007; Wed, 15 May 2019 14:15:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 293026B0008; Wed, 15 May 2019 14:15:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0AB86B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:15:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b8so332340pls.22
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:15:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v50nlXpVfnXeYNEuOAWmVcGj2GBr2Lsy6iwXW/Ee2xk=;
        b=onbWZtQi5J0a75l9/k//qay0XqxbgG3wbFwzD/604H52sr4zrRFNJ998yb7tVRDwWM
         3gvyvkSetLDVCtWm8kE8htssEGwE+cYtFRO0QcNpjJ9Gw8HDoTB+xSVKNETfM8DgcKM1
         R1CMwxIQCmFApn4L0HxI1bISGEwiPJX3etmx7KubypEsqnmQq0TioMQ4Xs2SXmRhdVZs
         GEHJvQ6l8P39HISMr+t068x2P+/pc0Kn03G+F2b8dII2J6WSmuKjoK9fVvVuYTfMRx2T
         GdW57I9+KwsbGH6eKIetVAYqb78NFr/O2IIxyL+P5jotNBWrqNmyX/D1O6xI62rmZ1hO
         f5/A==
X-Gm-Message-State: APjAAAWdHa2b7FqLcPdNDa01/QwN6QYDZiQ47FIypJZJ4hbvRloEwdWP
	/9tQhUGubN9/6p1EroqbLwf6X4sS50Sb+tWHlJGmvg9pB9SFH8OtaC7edAlovfkvpPO9G95vnoY
	rLPqj0fuFgTrSrxBEtue4fUFFdEiyL4ruRu4jjM5+arBAflBIUNngXPaLycm0bxnXog==
X-Received: by 2002:a17:902:7609:: with SMTP id k9mr46366303pll.335.1557944150341;
        Wed, 15 May 2019 11:15:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZWXKEfiwLiGOeNlhgr0om7KMDgsHWvJTbyw9LdpZx1t2tlv1yDKbDzmM+npamzzoh0dQW
X-Received: by 2002:a17:902:7609:: with SMTP id k9mr46366221pll.335.1557944149498;
        Wed, 15 May 2019 11:15:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557944149; cv=none;
        d=google.com; s=arc-20160816;
        b=ACYHBy+nhv7i6bHP4FXpLF51KJqEE28gqKEBR0gbwCdrdORr2x8u8xzUfDq1vE7bd3
         EwSOr5kY6MCC4jlksYbO53EjWmFDYc/9KisG//caETtn79flF2UpWd1vQQIKT5a5EN4U
         y4tcBOPkKJ8ZTnMRW7o/xtPyDhJUn94VGIEIZ42uBK0Zsqka5XFIm9+87IymzhCVoCwB
         E/DEX/qkL1GX8OP4F4Vg4qcSNfFyshdP0Lm52JoK9dM8dlp/PgqcHYEKI98xKyXi4KwF
         ffPnPItLWohcTOd289f5+9ju/JrpFrBeFvhJrixpNlt8AIx96MwvKRJZhjiT5b5luMqG
         glfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v50nlXpVfnXeYNEuOAWmVcGj2GBr2Lsy6iwXW/Ee2xk=;
        b=tB7ExBj+jWeXk+VntI9IWs9xcK1o8Zs+xRDZQ8XNmr1E4Sj/cUbjBlqwpTScvFiLhG
         RjGLTimP2pEEk5RqRu35OWAjZGmoZeEWnxIZ5nF/lN/ZZK6DE0KmFlZQPJ2UysohnLUS
         NjXD+WVWdAhga3zSfSBR1zCTk6u7gpXnEjdECjshSQHYkB4J6Gu44/EIJ5Vsk8UvgWJO
         pcx54B6K58pQyTeBp5M5nkRB0Uwp+XK7V0LbL9wQnNsislAL5mxAqmkrIZmxMtC97MJe
         OZqfXVDzVomIa/XOV3XtjOTy67P2pEzu5EpNGA9UL0Fh2+wRWwNJ1E5Nx+7n6S/lZtBL
         e3RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aW6+HG7z;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t136si2810576pfc.144.2019.05.15.11.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 11:15:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuval.shaia@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aW6+HG7z;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FI47PS172168;
	Wed, 15 May 2019 18:15:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=v50nlXpVfnXeYNEuOAWmVcGj2GBr2Lsy6iwXW/Ee2xk=;
 b=aW6+HG7ztSpn1tkLHF4Zv+JTF+cUwq2MXiwj33eLClqkEE9YtFUsjeBj6xhoA8D1zt0i
 Gaq/dYQKWwXGRbFHpV+QgPSuugL+KKI+ICnInOu2w94vcKVzycro04GwJxbQTpvIh61U
 BFgzeo0q+6nUqKu49hYnaJeFnImeoJiG1jNb6yaVWe0bgye9hkeyP5msjJTMOAKsKQAB
 XhGS/bXIkWhLZW8fvBwzOxvE2BvEqNmTb27ULEyWr9WfPu9PA+yhnbkfs7k707p1/vVH
 +l02xG0uHOrURHoX+ktYqnrRR84iEU8+KZKoHvwErYdxyQRC9Saj6gPtqnFcXUMilYRJ Lw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2sdkwdxvcf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 18:15:46 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4FIED17038245;
	Wed, 15 May 2019 18:15:45 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2sgkx3mnn4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 15 May 2019 18:15:45 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4FIFhL8024505;
	Wed, 15 May 2019 18:15:44 GMT
Received: from lap1 (/77.138.183.59)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 15 May 2019 11:15:43 -0700
Date: Wed, 15 May 2019 21:15:38 +0300
From: Yuval Shaia <yuval.shaia@oracle.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: RDMA mailing list <linux-rdma@vger.kernel.org>,
        linux-netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
        Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
        Marcel Apfelbaum <marcel.apfelbaum@gmail.com>
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190515181537.GA5720@lap1>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
 <20190515153050.GB2356@lap1>
 <20190515163626.GO5225@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515163626.GO5225@mtr-leonro.mtl.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905150110
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905150110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 07:36:26PM +0300, Leon Romanovsky wrote:
> On Wed, May 15, 2019 at 06:30:51PM +0300, Yuval Shaia wrote:
> > On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
> > > This is a call for proposals for the 4th RDMA mini-summit at the Linux
> > > Plumbers Conference in Lisbon, Portugal, which will be happening on
> > > September 9-11h, 2019.
> > >
> > > We are looking for topics with focus on active audience discussions
> > > and problem solving. The preferable topic is up to 30 minutes with
> > > 3-5 slides maximum.
> >
> > Abstract: Expand the virtio portfolio with RDMA
> >
> > Description:
> > Data center backends use more and more RDMA or RoCE devices and more and
> > more software runs in virtualized environment.
> > There is a need for a standard to enable RDMA/RoCE on Virtual Machines.
> > Virtio is the optimal solution since is the de-facto para-virtualizaton
> > technology and also because the Virtio specification allows Hardware
> > Vendors to support Virtio protocol natively in order to achieve bare metal
> > performance.
> > This talk addresses challenges in defining the RDMA/RoCE Virtio
> > Specification and a look forward on possible implementation techniques.
> 
> Yuval,
> 
> Who is going to implement it?
> 
> Thanks

It is going to be an open source effort by an open source contributors.
Probably as with qemu-pvrdma it would be me and Marcel and i have an
unofficial approval from extra person that gave promise to join (can't say
his name but since he is also on this list then he welcome to raise a
hand).
I also recall once someone from Mellanox wanted to join but not sure about
his availability now.

> 
> >
> > >
> > > This year, the LPC will include netdev track too and it is
> > > collocated with Kernel Summit, such timing makes an excellent
> > > opportunity to drive cross-tree solutions.
> > >
> > > BTW, RDMA is not accepted yet as a track in LPC, but let's think
> > > positive and start collect topics.
> > >
> > > Thanks

