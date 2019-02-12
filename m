Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3D8FC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:31:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CF3320842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:31:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CF3320842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D8C68E0003; Tue, 12 Feb 2019 11:31:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 260D28E0001; Tue, 12 Feb 2019 11:31:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101FC8E0003; Tue, 12 Feb 2019 11:31:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAA658E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:31:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so2554613plb.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:31:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=edN5MxTKmE1CEZ9K0riw9MeaICT7hT+QbpqB9wkArgI=;
        b=WPR+1FUAccRXfVEpCf/kLj2da/tbANgVpz0vAKy9aks9VqgsFTvKpetxyEcRdG3Vlr
         omL67RhZ6VtVexuTkJcPjbJNQoMnpGCzV4yBhbas03nMkNvqDm7BCizSphEwPXeSEHiB
         ECDASyH8SR/CHcRK7EBQmsrF9jZZL0NCyw9wsQ3n+TPotuZqXGDSeV0OnwRmJbrSFdcV
         q95Iwx6KmzON4dIH8UOt3jDdsBG2ngQpU2ybG5v1yTIOd/VwVYxv7UBqB2gmbp1zzLFu
         3KUKnqtq26edtOmwiPmtKvjpKJvu9mQgIH7+E2x8mWZYw8HPfjgSwvAy1PjISvnDR7J8
         zhww==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaua0ud6XA1PGJW8g+1b43Lxdcg3pqeg3u9KyQHLf9pAPPxLnZ6
	DJ/l6rNnYkS+mi+CoL69sez8hO0NqaOgEJ/5iLVD1pJ1/XeHvBicK77m6StOcjhnqTRIkxKK/cO
	Fao1a6fVCMzfoBCFH2uITuW+tFvhpjFjOpIJ8444xj8LeeAx5RDFVzskoZPpyZf4=
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr4704583plb.199.1549989087422;
        Tue, 12 Feb 2019 08:31:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZixNLdMYQfOCNhipDSQ7O9sekTB+mFPRYC3mn/8Kdy285Bf+PCxytZpRqWmmCJGKBspgbx
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr4704538plb.199.1549989086789;
        Tue, 12 Feb 2019 08:31:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989086; cv=none;
        d=google.com; s=arc-20160816;
        b=zWbgu2QvmYseS1UrTM7U3zz0DDbxplMrBlivKSQjG7yOFXqXhC6kKOtyzGzw91VGzC
         ALXkMFgSS2rAEjWg2Md3CBRJIdfmBUvYra9LLuX7NjllFTOMPwaVzFW72hN+Qt9ETXJ1
         vVBSPpvD8SkDCelgqj4FSSEz77yff9BCU7GjWhpWFFf7ztR3Fq9VZfo6Zs2Y0IFkBNYy
         IF5XD7x2OKzDoGo8coDEF7RsElfHBz+Imo82Syu4NozuZwZZgOkkcK1k3Osv45NH+zHW
         Yrm0o5gpMjDGwPm4Eabk7nb43SdM5wKt7UR6tE6xEt8mVa+9SQmVuelfLbT4Lmug4qm+
         H9sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=edN5MxTKmE1CEZ9K0riw9MeaICT7hT+QbpqB9wkArgI=;
        b=XgYIsII/VSZ1M638C+BZV/Qo3DERxtBs25TuQw3+n03EF9Lktmvlt4RjZoKJ62t3Dd
         zLY7g4zUHiCrchBv/Yz7YGToKgBjR5SIsJy/12i4NcpH8ONJLc/8L08dEodA/lvn9UwT
         YVXwTD6xVqZlyMhHQgslqGfScKUP3aiDIWvDh6eHCtL84b5vUd1bDEMm+K/r8kOQd05R
         LMD6Fdo9PpcPlOhsCiqb8Qx6zsGhJ9Z6WtLylzKJmPZm0ogh3jPILJPICFn+mfJ1uxuA
         Ae+C/Jx4+xq82PBBYfO2N+HdReakvyZ7TVkL6EkEvQRkZX/f0bVDJaQgMSzK4AXBuzMH
         N+Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 61si13889170plz.117.2019.02.12.08.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:31:26 -0800 (PST)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CGSrti060033
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:31:26 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qm0x5jth7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:31:25 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 12 Feb 2019 16:31:23 -0000
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
	by e15.ny.us.ibm.com (146.89.104.202) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 16:31:19 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CGVIfg7798850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 16:31:18 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5EAAEB2064;
	Tue, 12 Feb 2019 16:31:18 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 402A3B2065;
	Tue, 12 Feb 2019 16:31:18 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.41])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 12 Feb 2019 16:31:18 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 658D816C4009; Tue, 12 Feb 2019 08:31:18 -0800 (PST)
Date: Tue, 12 Feb 2019 08:31:18 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kbuild test robot <lkp@intel.com>,
        Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
        Johannes Weiner <hannes@cmpxchg.org>,
        Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Reply-To: paulmck@linux.ibm.com
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190212013606.GJ12668@bombadil.infradead.org>
 <20190212155610.GJ4240@linux.ibm.com>
 <20190212162518.GO12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212162518.GO12668@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19021216-0068-0000-0000-00000392B57D
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010583; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01160049; UDB=6.00605424; IPR=6.00940600;
 MB=3.00025547; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-12 16:31:22
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021216-0069-0000-0000-0000477BCBB2
Message-Id: <20190212163118.GM4240@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=826 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 08:25:18AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 12, 2019 at 07:56:10AM -0800, Paul E. McKenney wrote:
> > On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> > > radix_tree_iter_resume is, happily, gone from my xarray-conv tree.
> > > __radix_tree_lookup, __radix_tree_replace, radix_tree_iter_replace and
> > > radix_tree_iter_init are still present, but hopefully not for too much
> > > longer.  For example, __radix_tree_replace() is (now) called only from
> > > idr_replace(), and there are only 12 remaining callers of idr_replace().
> > 
> > Will this reduce the number of uses of rcu_dereference_raw()?  Or do they
> > simply migrate into Xarray?
> 
> Unlike the radix tree (which let you do whatever awful locking scheme you
> wanted), the XArray requires that you use the spinlock embedded in the
> root of the data structure to protect against simultaneous modification.
> So all dereferences within the XArray code look like this:
> 
> (if either under lock, or rcu lock held):
>         return rcu_dereference_check(node->slots[offset],
>                                                 lockdep_is_held(&xa->xa_lock));
> 
> (if we know the lock is held):
>         return rcu_dereference_protected(node->slots[offset],
>                                                 lockdep_is_held(&xa->xa_lock));
> 
> The XArray API doesn't expose slot pointers to its clients.  It hides them
> inside the xa_state's pointer to the current xa_node.

Nice!!!

							Thanx, Paul

