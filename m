Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66DB6C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22181217D9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:11:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="h69/8aLc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22181217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B39BD8E018E; Mon, 11 Feb 2019 18:11:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8B98E0189; Mon, 11 Feb 2019 18:11:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FEE58E018E; Mon, 11 Feb 2019 18:11:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3E78E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:11:57 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id r85so1194004itc.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:11:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ga+yuNAdN5EDRIg9ZPoAnKRUBklhIkTaF8GwpER6yuw=;
        b=DMf43PsPEUIx7/jyIVA7p0ZFcvHxaJIgWLCwf6n0Sq6PIjJHhDHN1IHIbYXr7dsP/X
         agSFBMsdRLjhuU3k/9KTRlEUrA1/r07y+LjxYJQUrOMUaDS3wiFTOrx/XDTicc2kQZY4
         1+Q3E1aYDXKqXyjrrpXF83HVDyMrnNfzlIfjvOZkmp9HlQNZgYoc+N1HDlO4qPuhldP5
         WnnIpXaUoApw80O6x6MjE2uoQicYur4boCW5dRCHzRC6pTI88eyb+pfoySNaURMNrXIM
         jObMDfV0jxbkEurY8Yco87vZYyjgZ8v98wKd5jbDi57gyzQFfBrS1cSAW4br4QQWQ2Lq
         AGUA==
X-Gm-Message-State: AHQUAuY3Yr5+wZq/jBYpMyBChuO1ytsAx6YpULMS/AbMNcqUNKq+ge49
	2y9Ff3enj0Hts2tAvaEAGSAzZI4AZcVBp+/wHJv2TfCNMPPN+Q/A3G7qEvciZKjtVuA2G0IYNLb
	b49avK6G0aqc1gjDiRfIjofDiO/IjKg8NUFz3jNj436x8v5yl3uy3UB9R+x2eR/9UWA==
X-Received: by 2002:a24:a507:: with SMTP id k7mr333214itf.98.1549926717243;
        Mon, 11 Feb 2019 15:11:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSxfythN2P0+W95T2fs6NjBxq6yyz4I9AR04hEsOb57Zyd1nxIX1sI1JSQUKZtVo4/w31B
X-Received: by 2002:a24:a507:: with SMTP id k7mr333199itf.98.1549926716653;
        Mon, 11 Feb 2019 15:11:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549926716; cv=none;
        d=google.com; s=arc-20160816;
        b=DwPfltQkzkjhOsw3nvEPJ/f8zWTHsTohREBPAAIwomkj5FMzexYo0SRCFcmpCdf31A
         Tq+yQZ59A9a4Fnt8mkybgzh9Xv8ZU43WIebNP7eVeoG70wZ0XDalQMZZ1ch/VtaDiO6s
         eXN3ilEBIrX5FJh4TyqWij/j3eucPaBPDxd3peLjTQyqwTQ58I52bydjAWvVAssHDYa1
         Ks/l5qw+GcKgAkDlng3/f1ixX16zqDAViiowS671gpt3FHWWwm/0QFuprL7jdi1z1XYd
         Z4ckbiG4pSfEcc/18QuphzfaXwQu1lPLkkuUPER2+xVJdSmumcnMFec9AmUZAJGiC5Na
         cX9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ga+yuNAdN5EDRIg9ZPoAnKRUBklhIkTaF8GwpER6yuw=;
        b=nCDjkWiq0Q+Atv5eTSpWY9kpOB07K6Y3rzok+HjXGfqHgYr2btaiftXMjqyD8QUTHt
         dozFKt66IvEk9qc9/zmzLbKBgxbueq4MNHkTaGy/amaWflZjEhH+4/6XtY6zeBonqfam
         oKQb7aojlX2xN7TySLP+dvWyJ8vvXHZYTqxbgBBetqUTsqU6D0Xir1EAuWAaRVOBO7mm
         CDNEQCvW9ZsLm5NiakYn3MD6c452SMe3QQm9Ask7QY5HoKH6eCs5zZqE34X/0AZWAhIH
         JrIP7PodGBI56lCkrlsk23WqwWmfq+dicN4Ig5+CG3H65pgdYxv5CnH0QtkgpbepcVQJ
         Zomw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="h69/8aLc";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l18si6866745ion.25.2019.02.11.15.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:11:56 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="h69/8aLc";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BN8lYP097599;
	Mon, 11 Feb 2019 23:11:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=ga+yuNAdN5EDRIg9ZPoAnKRUBklhIkTaF8GwpER6yuw=;
 b=h69/8aLchyz1bOEzsVbEL12ex24x41iHgKUkVrwI2tdVl2pvNgzF2CVbB+9+XUW4pN4d
 bl9vR+y4J9EMrCCQ5llzSpmryKAwte5EQnwEnawq2ien/vrHLSsd6JOMlls3kU+lvsJW
 PT08I9Q2N5KweZXEp+4rSAVoD77ka9orD/Q+b1yO1ccO1PNqK8ykHoP+Wdo1s4kHAPHB
 IsrtNH7jey307PkgCXznIEFiBmEZ6WVutPqCFE6Q7xfImKruBX2+e/+J5Zf73XeaHABu
 aE1PZmOGQ6oN+gnBJUtGRlrqCl3mGAj+YbEuaazQ/okXBVk3PhEEnlqDhkKd1fuI8M66 9w== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhredrtp7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:11:42 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BNBZgL029359
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:11:36 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BNBX8o019495;
	Mon, 11 Feb 2019 23:11:33 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 15:11:32 -0800
Date: Mon, 11 Feb 2019 18:11:53 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
        kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to
 account pinned pages
Message-ID: <20190211231152.qflff6g2asmkb6hr@ca-dmjordan1.us.oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-2-daniel.m.jordan@oracle.com>
 <20190211225620.GO24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211225620.GO24692@ziepe.ca>
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

On Mon, Feb 11, 2019 at 03:56:20PM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 05:44:33PM -0500, Daniel Jordan wrote:
> > @@ -266,24 +267,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
> >  	if (!mm)
> >  		return -ESRCH; /* process exited */
> >  
> > -	ret = down_write_killable(&mm->mmap_sem);
> > -	if (!ret) {
> > -		if (npage > 0) {
> > -			if (!dma->lock_cap) {
> > -				unsigned long limit;
> > -
> > -				limit = task_rlimit(dma->task,
> > -						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > +	pinned_vm = atomic64_add_return(npage, &mm->pinned_vm);
> >  
> > -				if (mm->locked_vm + npage > limit)
> > -					ret = -ENOMEM;
> > -			}
> > +	if (npage > 0 && !dma->lock_cap) {
> > +		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
> > +
> > -					PAGE_SHIFT;
> 
> I haven't looked at this super closely, but how does this stuff work?
> 
> do_mlock doesn't touch pinned_vm, and this doesn't touch locked_vm...
> 
> Shouldn't all this be 'if (locked_vm + pinned_vm < RLIMIT_MEMLOCK)' ?
>
> Otherwise MEMLOCK is really doubled..

So this has been a problem for some time, but it's not as easy as adding them
together, see [1][2] for a start.

The locked_vm/pinned_vm issue definitely needs fixing, but all this series is
trying to do is account to the right counter.

Daniel

[1] http://lkml.kernel.org/r/20130523104154.GA23650@twins.programming.kicks-ass.net
[2] http://lkml.kernel.org/r/20130524140114.GK23650@twins.programming.kicks-ass.net

