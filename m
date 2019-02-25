Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 545F3C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB4E20989
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:34:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB4E20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA76B8E0176; Mon, 25 Feb 2019 03:34:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54BB8E0167; Mon, 25 Feb 2019 03:34:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C43988E0176; Mon, 25 Feb 2019 03:34:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 984578E0167
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:34:54 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id s8so8450825qth.18
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 00:34:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=J0O2hFZuyGkD7iwKTvYt8eIRKvFnZJ2SxVegxFdAS+E=;
        b=mKTlx9dh3tDZ0EjR2oZWKiBNnkDNr9djnq0ggzttNuWNWaBZ/z9ZHMGHYOs1oruir6
         viAWKgbQeLx7pYl8Bmvza94UEEEXO1EtusN3JefS2rey3MlzfF0hDCDr7kgL6IdLJqZC
         8pcWQLPMWMnkmQXNW2DC+ud/rfts+sRpLfV7mupdHWMuCCWnyE/s74MmfdU4tTRdF73n
         baRfBpnWXNcZYDNcJWHdjZN5T9xYAwpo9vI2UvqnYAlFGhoTcEVGLBvv3iLBYos2b3Dx
         5jPIus8BGUmWwMyOc4isfncZ/ScBVRbFJbiIilvdPl+vQ1sFz4HKPCyQnFTPm3FJo+L3
         lFng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZl/UsI3oOfs+LWmio/VoT7GJL33KZKuW2VxFoE6drH0hoGXQk3
	29oyVk+lqaZ/oIdZIhKkXolGKnZ7cABknvVS4AeuDJPYNzjkAsw/X6V7m3tu4HsJ8Md3ecCJq14
	ABNjIZE3nZu3CiQp19Eo7odBHdJXWIUCEryBpD86jdvRLVweXygd+IfDzTBttGwCd6g==
X-Received: by 2002:a0c:8b50:: with SMTP id d16mr12439864qvc.233.1551083694401;
        Mon, 25 Feb 2019 00:34:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibwy3AlPhfYbKzzA6zlKfflzam34zPrmsYphy6BKlkf2Z3DcQrN8RalGRU4MCU7bgy2ehAS
X-Received: by 2002:a0c:8b50:: with SMTP id d16mr12439843qvc.233.1551083693887;
        Mon, 25 Feb 2019 00:34:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551083693; cv=none;
        d=google.com; s=arc-20160816;
        b=ArjMxv5y2b0QPIw5NQzd3zsu2kXXfbEn57ZBfJGGcWKWQ8n+RWJ5DEEWMN2bkTWnOo
         0ny98LanNLX3iVbdzQ1uu6Uh57sQ0A/V/Dg+kS4PrDClkYVSukyXT6Fq+BONjdSuYuJA
         Z0dVvBxTHfYn0G4TUW4zcKX27kBqDacrco1hC/NbgO2fMofTW1IR75690zrzKbq6gwml
         x8+8WL1NcoYIEncv9+cqt1CZz1tYHSkmqkkaPbwSCHdRZa9+0tPZh7Nt7gX2ks+nyQOJ
         PXfno7/hYyzbjuuS6+Lc+NMndein+QB8m1QQd6HBud9Ba2EvvY7lANnlbp14wcdAEujk
         nN2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=J0O2hFZuyGkD7iwKTvYt8eIRKvFnZJ2SxVegxFdAS+E=;
        b=jEqTtwaER8hDg+KFafuVgwPgH8YTrIGUoefNbFTUccDZLho3gowbpKzkea57BeA7FY
         Lru2E91Dsk3TSdqZ5wXx4D+OJ7TLHTi0Ltf9t/Hz0u9L9cKH6ImUJBRwIpwMIcA97qLp
         4ron8iouIosgU2CWa6TtL/tYq8LWDW8aXTKPCBuJLx4R3fcK3jDKTCNqEoLFjltqiYXa
         90oMNuEVjyJRLUrG9+/jYZDE/XH0IhIpx8m1Rp1iQLqqz+GhgeC/gTfp/UP+cktJYC+M
         FclcfdED5ZrS5eWJy4Rg0DFmbRA81PX4bMWd2ZahvwvAAEyrHDHIKnELVf2bfCZGzEc2
         /wKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v74si790279qkl.213.2019.02.25.00.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 00:34:53 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CDD6E30832DE;
	Mon, 25 Feb 2019 08:34:52 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CFAD55C223;
	Mon, 25 Feb 2019 08:34:41 +0000 (UTC)
Date: Mon, 25 Feb 2019 16:34:39 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 22/26] userfaultfd: wp: enabled write protection in
 userfaultfd API
Message-ID: <20190225083439.GC13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-23-peterx@redhat.com>
 <20190221182926.GU2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221182926.GU2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Feb 2019 08:34:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:29:26PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:28AM +0800, Peter Xu wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > Now it's safe to enable write protection in userfaultfd API
> > 
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Maybe fold that patch with the previous one ? In any case:

There's authorship differentiation (previous patch was FROM Andrea,
and this was from Shaohua) so I'll try to keep the current state if
possible.

> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Thanks!

-- 
Peter Xu

