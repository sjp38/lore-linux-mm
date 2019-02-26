Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4176C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:11:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64DF2217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:11:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aaszYhEU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64DF2217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E76128E0003; Mon, 25 Feb 2019 23:11:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25758E0002; Mon, 25 Feb 2019 23:11:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEE3C8E0003; Mon, 25 Feb 2019 23:11:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8365F8E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:11:06 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 17so8647163pgw.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 20:11:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YvExDddq4M/SVqwop6GFX1tVTd5CG7BGv3x/6RAwRNI=;
        b=hY/owkKGTegZQ4OznUU4iW+S5pUBYmUzQfcz6LiYdaWHYJottdashhUGq9lzzzPAHA
         dYX5453B/pazzhPd1R5eumD11Rns06FSqUQE76GuJOlrjqYeAM7fXAofRPb0DG1K6fRK
         IYVwhuNbuRMomBtWLtzVaJFym0NBk1Z1GUOHju9DbncqVrmN1E8/4fkaMal+teqtdjI8
         TvleqqMK0tAu5JJ/m9n65+SNkxIJd4RAhyimRtgNDSUR9waNkk+yohdW0iaNepNvtloF
         /Pf6wuBTmKkB8QlbKXGmcgoe2/wTy4gUVUWlzLe9cRLaXEOvfO6kqZPC0AmB5DP2b+cu
         gfGg==
X-Gm-Message-State: AHQUAub5gJWWB1r7mlLn3h3h6VLrgM3QZa3L4oKsCim53mIg9D8iMrU1
	hyYsyXgnJz+dZXYYelrVF4wtKHNVcXXEzyzedp+fRew7Sx8XXCtNToeiw1+YzT5qtq5bjpxM2mF
	fqL4luz3bFMh2VNpanVtBYNoCPafRTfYC7PX8+nAfQHjl2KypO5IU/kSUm3dnzlq16w==
X-Received: by 2002:aa7:81c5:: with SMTP id c5mr24398077pfn.217.1551154266167;
        Mon, 25 Feb 2019 20:11:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZl1V9Vc5D0fpyUO1XUVLd7PCMPFxj9qFV08Y/WnERxpjRUyj6uPWq6Sm9Z9WIzjaIJF/7B
X-Received: by 2002:aa7:81c5:: with SMTP id c5mr24397999pfn.217.1551154265013;
        Mon, 25 Feb 2019 20:11:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551154265; cv=none;
        d=google.com; s=arc-20160816;
        b=e6fJZK4giuIypgp9aA6uAJPzzRyqhe73/QnVaBx9MlEv8vD7IkEOj2sNeUsbgd+Xuj
         aVfZDlYL9VYpbgmo4XTHzs8ApVgl7Ztm4Jj7G24yeHuc1nTbQ9oJ6DgXwEVM1yoAkVj9
         0ba/aQQM6PkHk8rx970QFdMYxXSPRvGxqzUbKjXPj7R1U33mR6ywql2HVMtAve/NdfRc
         namW+a42FLTbvVakhNVMUFP0xPT5ErxdGgo7+oWWuqkiBDy0PpUU/V5yzAuIm/JjSquV
         UIMDt9rz3cSBabQm19pproZI5pMB5R8PjHZkkEMTJ4KhTrcqiky9gEH71LOPMIW2MvBk
         xQMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YvExDddq4M/SVqwop6GFX1tVTd5CG7BGv3x/6RAwRNI=;
        b=HEN9MqZfOzLXong1r54YLXdfNKVLVpe+wb4ifK0ofEy5hDIoLtk31RsRhAAH0BwOGH
         QwbEafMvA5cKpuu670QiM0jETYgBb2SfRzyhpOI40zZHUe59LXvBkKeua81bFdDF9KKq
         8ab9/wjDVVHazqzwApJ+nZGHF1mQqUjgxsFfcDu+0rUw8lRxaiSqFB91BKHqHD3darxW
         bOcBH9RtQbpF/P0T35EIilPw2hrL4mt8lCBvtmhaL2uNO5KHoVztxk4x5O611CDuLOZV
         GsDM563Psef1bfePZEYbK9UvNK1lStruc0s11UyH3k628Iq9d5HKx1AAdgqj34a0Bxz2
         xSqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aaszYhEU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f14si10505593pgv.262.2019.02.25.20.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 20:11:05 -0800 (PST)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aaszYhEU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1Q0TC4A067132;
	Tue, 26 Feb 2019 00:29:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=YvExDddq4M/SVqwop6GFX1tVTd5CG7BGv3x/6RAwRNI=;
 b=aaszYhEUFFCSiV8WNnygJKWiyhPP2VG+uKFjpZaxiRPlro75d4rg7zh4tJVsK1ekmXUi
 Z600cPI2yxMDWaYBZF4i5enjfRLqHUl2QodzDk8VjOyOVU7eci3Xj75DEafP45zBpzDg
 wwkFAdpuGg1AJLP7yOR3SulOHnYRwpyVOEI77IwsT+pBSjKS1rtWnXqG8Mq7qYJ3Epkh
 0qhgqQtLDKmI7Tt98ejelfVEfR5nEXM60u1pvqslnv1mx+QDdUz9ZLailLoxh+BDIlpy
 86zviocBbjcEeu0TzPeESYp/l/Y7NoJaZhCkkGwxkAYsofs17wnYF1mij23Ptxp44Z8h Ag== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qtxtrhhvv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 00:29:12 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1Q0T6PJ016173
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 00:29:06 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1Q0T5tq011329;
	Tue, 26 Feb 2019 00:29:05 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 25 Feb 2019 16:29:05 -0800
Date: Mon, 25 Feb 2019 16:29:04 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Hugh Dickins <hughd@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Matej Kupljen <matej.kupljen@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
Message-ID: <20190226002904.GE6474@magnolia>
References: <20190221222123.GC6474@magnolia>
 <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
 <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
 <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
 <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
 <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9178 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902260001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 04:07:12PM -0800, Linus Torvalds wrote:
> On Mon, Feb 25, 2019 at 4:03 PM Qian Cai <cai@lca.pw> wrote:
> > >
> > > Of course, that's just gcc. I have no idea what llvm ends up doing.
> >
> > Clang 7.0:
> >
> > # clang  -O2 -S -Wall /tmp/test.c
> > /tmp/test.c:46:6: warning: variable 'ret' is used uninitialized whenever 'if'
> > condition is false [-Wsometimes-uninitialized]
> 
> Ok, good.
> 
> Do we have any clang builds in any of the zero-day robot
> infrastructure or something? Should we?
> 
> And maybe this was how Dan noticed the problem in the first place? Or
> is it just because of his eagle-eyes?

He didn't say specifically how he found it, but I would guess he was
running smatch...?

--D

>                   Linus

