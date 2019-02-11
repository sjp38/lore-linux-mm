Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05AFFC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8153521855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sImR4AoR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8153521855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2360C8E018F; Mon, 11 Feb 2019 18:15:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E66E8E0189; Mon, 11 Feb 2019 18:15:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AE828E018F; Mon, 11 Feb 2019 18:15:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB7158E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:15:51 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id i2so471002ywb.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:15:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kB35uu3MDCX9H9dCjyeKgUX/v73vE2yZBRGVSmwnBFk=;
        b=YYlQIx9hOJVVLk9X8j0Zdpidc0lYPYugs0KmyPY0bzlnTrY8LOZuG79SxEdyx/EhHS
         fGevj1DffisK/rz0TlaRNMkvdDofowbsFdNT9nNCWKUi1nsM/wYqf9ok9AzmKhLkAff0
         bu7b49oztX2KHr29S04x9qLH0ZvPapjVcuJT5qdv5mBSn3zrvtzN6br7mfENEBpadq+y
         yxnSGOhgQSviaI0I7YtbaXTuw4yQFGgy/oiQTnduJEV49b+WCtNwZLWHbo6l1lUYxgql
         dkhbio7U7RHQKiD1SMAaD4tVZjh6n5/+B4cduGoBZOl5Dik1gcuf1aI0YzjHMjElPzv7
         bK8Q==
X-Gm-Message-State: AHQUAuavVlfUaaMK3BBF7jNVpsPeynet19GPGdYMZn9LXRzULecVkkAv
	gzFKIa/uFFX3ZOcoVU0Ew6PlZP79QY+eiy8BQBMR/sY1ihmQv6Lqlfh0dsytvMhSZIpDOLpSqmq
	GIGJK3fHnIIaXoHucBbxni2x/5rkRw1KExzZKVyzPzgsEHsw8oj+EFRR41g7BeQ6HTA==
X-Received: by 2002:a81:9895:: with SMTP id p143mr504056ywg.317.1549926951483;
        Mon, 11 Feb 2019 15:15:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpYH7IMJRgofkFTs4ltCYBjPoRSL8cPjhqPledsTq9wVeOJvoFFnxD2mkeLL2ufF+QCzU4
X-Received: by 2002:a81:9895:: with SMTP id p143mr504024ywg.317.1549926950975;
        Mon, 11 Feb 2019 15:15:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549926950; cv=none;
        d=google.com; s=arc-20160816;
        b=a4B+qY4oOQovBIMvQvT4h8SmIhPlKDxb827hCGxiPBFUO7ZOiv11Tac6ptevNnWx/V
         aeI1cgXOxlffhkvRW+f//ftAkU5MiIc/35vsXzjD9lpG9G0HMLjGMQkCGmLb2VCZBM0J
         307lyxYpfvtxd/RoDguBU+bWOZZvd6TCCWyQWLUFQx6zHsoK2omYJQ4KOTzwNOc5hC77
         zkaj3fwFf3301KuycFpcgN7kCwVEcPgfrF1sblLnkiLHq26nezk0DeOIeUbzXWJiV3Rg
         96kOd8WTuUyq+gF+8VTiPR5XHWOHYFiQWoZv9W1RvvPp5+sPQJbL7bQ/ELC2InMOzpvO
         gUGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kB35uu3MDCX9H9dCjyeKgUX/v73vE2yZBRGVSmwnBFk=;
        b=MdQpwEN2rU54eUj1Nk+56kTo40f0q9dnyoXOb+3SYdnZGrsET3ODXH8LZ8KKqa1nY+
         9vN3KNHRQ3XIJ8wQU5otwaS78Jy1bODUP6bRJwLqUtgCA6tr6/9Mt75HaeOgeJIyyZcj
         1ymPovEsc6u0+o5JlrzMOXVY/JgGOusihGzbopoFE3r3sC5KufIOahhLn3AE9zekAjoq
         WI7SOZqXIoZ0BTIDJIGOUJqM5SQo971fuz6u7UmoGHTGhuLpVipuPoi3RdtEJDiA8fnJ
         axsSAj9R60kbDH8BsdQ0DQKaDtGYKWvUsJlhGN9HQwHxfLP+HBddyeoLi2z2qF4BWCJX
         ggLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sImR4AoR;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k76si6932572ywe.420.2019.02.11.15.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:15:50 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sImR4AoR;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BN8vX3097642;
	Mon, 11 Feb 2019 23:15:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=kB35uu3MDCX9H9dCjyeKgUX/v73vE2yZBRGVSmwnBFk=;
 b=sImR4AoRO04ITgZA5uD8ntFkY61H4DFWWhC82mHzH9Zl2/tm4ppiBGBzH3eGXDFAONxu
 GPbTUwLmNtXzS9vlCQc2DNeKtf4yohjpVNHOcZAEHr/gMpSJ0PFOUAFFar3FSj7NFbRU
 LDHQLdx8+c1ikyFZIbVOEf5S2XH/iEwlooItddvKSp5I2mRQbelzMicK1FOsyLZnOqFH
 0VBiqzAP8poy/KL9WZYh1KxfpXW4mXA3IYj6m0bUUz00Q+bs2+7OjT5otMhuOn+DeB1S
 Td1dr3nTSQUyt88UnPnHUIppC6+JMHgfdf4/zPd8wIEyo+5mPUuhO9mM4PSXkz8ndTfa GQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhredru4n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:15:40 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BNFdk6008719
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:15:39 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BNFbVA021521;
	Mon, 11 Feb 2019 23:15:37 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 15:15:36 -0800
Date: Mon, 11 Feb 2019 18:15:57 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
        kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190211231557.zrcq3tv7qi6lqtvo@ca-dmjordan1.us.oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211225447.GN24692@ziepe.ca>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110164
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 03:54:47PM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 05:44:32PM -0500, Daniel Jordan wrote:
> > Hi,
> > 
> > This series converts users that account pinned pages with locked_vm to
> > account with pinned_vm instead, pinned_vm being the correct counter to
> > use.  It's based on a similar patch I posted recently[0].
> > 
> > The patches are based on rdma/for-next to build on Davidlohr Bueso's
> > recent conversion of pinned_vm to an atomic64_t[1].  Seems to make some
> > sense for these to be routed the same way, despite lack of rdma content?
> 
> Oy.. I'd be willing to accumulate a branch with acks to send to Linus
> *separately* from RDMA to Linus, but this is very abnormal.
> 
> Better to wait a few weeks for -rc1 and send patches through the
> subsystem trees.

Ok, I can do that.  It did seem strange, so I made it a question...

