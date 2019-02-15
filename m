Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CB1DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9F7121920
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:31:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="DW/4HFBW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9F7121920
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568258E0002; Fri, 15 Feb 2019 13:31:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515F38E0001; Fri, 15 Feb 2019 13:31:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C048E0002; Fri, 15 Feb 2019 13:31:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 172158E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:31:38 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n197so8891367qke.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:31:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=TXLgFI/pw+0pz5gj7vemkVrKIPPDAgFksp2sfKSU0BM=;
        b=eoHJq4uSNUs5dYZdaCaFLofzxRJ5W32PjktxdsUP93uSUYuQk/wn6rlV3kLjECSzTX
         oc3MDKvSf2eKdb/fjxcQL4CkqjgNUwHwrKI/wbEP7Fa8E1Y2PZfDvc9QtsZ77NbBPCog
         af26tayeH12OsAl7tKYP4WLB/sPmYgEqBbr+Y+21yB96f/FiQafCQsBZMKRs6u4lq24W
         XGV119ebN2NgSSrjKrwLgcEJmJGDB9wJyi8tJ+oB4yhU15ous5/FX34rBXDA+xuxlyXL
         sFVPLVqE/4xkokmmj+e17TCNxNJQw9Qe2fW08lR06B83GzkHd1xUHk18HAtWNKf58Bs2
         Aq+A==
X-Gm-Message-State: AHQUAuZfbHTnTPNk8FO9L7nL3Wubdjb4yjWNkTzSD+5lVBCh3N3FFkb8
	osk3sp7dUvKGImQBzaq46PmMTyzJU7qzHLn/cLYtme/AKYAh+N2ETO6oTclATavgiYv8eL2MLrC
	YPpgPzrRlg5SVpF3h2dOH7rBvJwivxkjlHVCT6vXXDWXD4OJ42bK8NwUsj3D9eFg=
X-Received: by 2002:aed:3964:: with SMTP id l91mr8702521qte.33.1550255497808;
        Fri, 15 Feb 2019 10:31:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDpPZTwsNNtKv7Fu6i7/JFSOQDZcVSJD0Z3u7CCwfMF1NyYIAl2J2bgpF1jpJwNj9ag7BF
X-Received: by 2002:aed:3964:: with SMTP id l91mr8702478qte.33.1550255497201;
        Fri, 15 Feb 2019 10:31:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550255497; cv=none;
        d=google.com; s=arc-20160816;
        b=kPBLIzjN1rKJUQmOCxSrElXRPadp8MfsdBqBIse8K0sr3iDkQapXCo+abLRDmtj/od
         KYutN/mXNki3ZW83OFhxxj+6L8FYvYjld/zuvDfnS0ZCq9Pl/975M/c+N20J0dfumhEy
         DPudErQBHcIi+qxMI4DAwTrmABROinXWjhCq8wNF36ypxR6cz1IFXgLPmMjEmwqVtq86
         /rrAqB8KINKzUS22ykt3rHa8hq91eeywA7JnWYLipJLFNrHXup1xSFg8jGqUKCheRHf6
         qsFhHK6QP6+Yp5426gv/HKT7WpxEntI/wFVLhoA0f1FknToLH6un64jA0E4hJguxcmpE
         aQog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=TXLgFI/pw+0pz5gj7vemkVrKIPPDAgFksp2sfKSU0BM=;
        b=ZJ0F5l+Nd5gzh2BNGdIEarbc+waYHzmtS2cuLt9Ri3BhP2GISd/h6p0hlC1PrtZYpu
         VSazZSeYnXkcBmEcEXeyl4pyrlBQwx0ByLhaZKbn1h0JyyJAiimlXFXQo5omdkJGwSxU
         X5GrJDtmO26U+okAaw0kVuJ39nDuD+tyKjMkuYg6aTgHVRs2DHj32XaXEQEcoewhhZKR
         JGdQxEwxYfZmBvoJGE5BXMnztTWDPyG2+tl3KxWumiwSLdAz5HD+/oDE00Md40jbY/3j
         letQDzfc7mOpBOdxE+g+SYMJaFWip9L/3em0WzR84lQCCRjQqLvQUUlQ+UNAX1F4xgJF
         vkYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="DW/4HFBW";
       spf=pass (google.com: domain of 01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id o127si797402qkd.13.2019.02.15.10.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Feb 2019 10:31:37 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="DW/4HFBW";
       spf=pass (google.com: domain of 01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550255496;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=FL49OqYV7AJ7BdfqMIiruaHQ/KIj/D+PCy38BhKpJ8M=;
	b=DW/4HFBWl7QxvxO7+RPK0EnTWciRC6KBevIyCX844sINXkFtro9foTj9NAy+yYNH
	KkrA17PnOuoFvHC503Pq6MYSRDKVdvWqqN3P0WOo5yW2T+28qcy/csPN+XvNkMyOgJ1
	hDFPRkfFHIw71VRLb6JkcoK1iXbQB5k8exBjyM/I=
Date: Fri, 15 Feb 2019 18:31:36 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, 
    Jan Kara <jack@suse.cz>, Doug Ledford <dledford@redhat.com>, 
    Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190215180852.GJ12668@bombadil.infradead.org>
Message-ID: <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com>
References: <20190208111028.GD6353@quack2.suse.cz> <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com> <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com> <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com> <20190214205049.GC12668@bombadil.infradead.org> <20190214213922.GD3420@redhat.com> <20190215011921.GS20493@dastard> <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
 <20190215180852.GJ12668@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.15-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019, Matthew Wilcox wrote:

> > Since RDMA is something similar: Can we say that a file that is used for
> > RDMA should not use the page cache?
>
> That makes no sense.  The page cache is the standard synchronisation point
> for filesystems and processes.  The only problems come in for the things
> which bypass the page cache like O_DIRECT and DAX.

It makes a lot of sense since the filesystems play COW etc games with the
pages and RDMA is very much like O_DIRECT in that the pages are modified
directly under I/O. It also bypasses the page cache in case you have
not noticed yet.

Both filesysetms and RDMA acting on a page cache at
the same time lead to the mess that we are trying to solve.


