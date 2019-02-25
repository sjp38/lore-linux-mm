Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5010C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 03:17:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46214213F2
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 03:17:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WoKWNFpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46214213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961568E016B; Sun, 24 Feb 2019 22:17:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9106A8E016A; Sun, 24 Feb 2019 22:17:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D9668E016B; Sun, 24 Feb 2019 22:17:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 354AD8E016A
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 22:17:49 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 38so6352351pld.6
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 19:17:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=3hqHXO72C1pMmktCE8lDSqZjAXGOL5gPjm/u1LuEqsY=;
        b=cXnz69xkiuAzzSIOAAkM6J1gkc9UAYX6Y65pWjR4jnQjrsOYgRhL8mcKOYV9yCDvN+
         tDpUiz6I4nhbixSyi8zYBdsQ14uCNu0yDRvBaITw7UK25a3HR2WDT9u1FGdW/eibTF10
         0v3MRU/VDyc5Al3W/BZbW4K6DoLVPLXVIfTxFV/RgUGldc+/4RtyxCn5ciYzM0dhnZNY
         d9075Iz4p/WPhYXXsQIUOD2qltkJTQVkmlE0iLKpLPdCUvaHdRuSM9Eo19u1z83aFbvQ
         B8qHwcxt/pTMeBN7ilADYf0zlttZP+Sa8Dq4GmmnyRHcV2YMOLU8XNWPNSDfA1RC1whU
         qKXA==
X-Gm-Message-State: AHQUAuaWYiFEiyjWZC1Krn0lUOZSAXDvtVslFcar5yylZVYtCBtVnGZc
	0S2We1mezcB44QUdIDFoPPCSjox4uDaW/iy1SirEebgv9NVL5Raf5j4x+Ad9FgON0IzXxFjDOte
	28kZ/nsCQoOyZsabTjOa2bC8WP8l5fyxiOArc9wlHBxhm1ERTB8j0t8muq5HHf1IH4wEpLyNMn9
	WiiClm/MFS/8TZjmadQcQZmC64u5vMHsAzIri3/bsaKipNNYPWtlRyBB6/IUwXlfg/kVCxUg+Lj
	M6eO8bB4Pz6hc8Yz25L0ZwPqJnCbMYMuE6Y3/WyEAdxNiuiCUTg5wBU26W5Ih4xWIdg/Ef3Dpvs
	iOqRrZeal076WdgVNoqzIBjzdwEfwIBzD0o4pGT97FWs0We4iBzZEcH+AjkBbyzTZboiad5IIH8
	m
X-Received: by 2002:a63:f718:: with SMTP id x24mr17032491pgh.107.1551064668715;
        Sun, 24 Feb 2019 19:17:48 -0800 (PST)
X-Received: by 2002:a63:f718:: with SMTP id x24mr17032390pgh.107.1551064667671;
        Sun, 24 Feb 2019 19:17:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551064667; cv=none;
        d=google.com; s=arc-20160816;
        b=WUmgl6/I2fBXAiWnJeZ7a/jXvVRUJYb/vvsJwysfK9GtuS/CFARwbUmXcdVT0+BVlD
         DR3KLkjz9uYeRNCMjrZklX5TY1X1XvB7qCWBkPuFZTKiwvNbY2svrRjRMhFfFcTjWuTW
         j7ShdMBETziRoPlikB3OFzON3Bh9eSlf3oD0DnHkeGy6ld3P9Y2DS5M4AwiE3v7Dva0Z
         pGHjwuSP8OZq7fkFZl/H8qtN4gCQLQOpu9LO6iK3Um7kPITVhUS+jQE26dTCy16Ep9LI
         +NbwEvvXeAgVdvdAMP1/wt/m20MoqH+IBMCnoHk9cJ3LWXoLJoxs/tbJ4sSxpJjnxkk2
         Cjbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=3hqHXO72C1pMmktCE8lDSqZjAXGOL5gPjm/u1LuEqsY=;
        b=t3jPKn1memAWrL3jioMAMLzoqGARm7Q3HXJ9zBhNG6Sy7tXRslJO6tduPt1iEx6ffY
         DlHBM16sZxm5iklVb9rQpWvleaQD+xCvU0iMbr2MojAPwtYoLvJ6ZpU2QB83gcWuBD3L
         OkueXdErvsNpjV1+Tfw233anIgIiJyOhr/aG+dZG+drMdR2UpMcYuvoO8pJVs2dO8K2l
         Nhkrxf4bwntDlc0YGQOxshnvCXnU90pgGwznr9sp5fB/WQNkK5/08/fDuXnH+VxWgIkl
         h2fbYHpAiULVYfwynavei6OnBK+stSBM7RuzIHxg+AW5hSVY+1W61b7b8GnlLwt0xhCk
         iWqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WoKWNFpe;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor12133010pgw.44.2019.02.24.19.17.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 19:17:47 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WoKWNFpe;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=3hqHXO72C1pMmktCE8lDSqZjAXGOL5gPjm/u1LuEqsY=;
        b=WoKWNFpeqO+9fJm+2Yykir+w7q1YpgJzrgrV1TLQpDdpFmIRO1Yb3HtpcNunjefWyi
         XrGUEdpzhQus31HR1KKKggztb5ep5ykid5pc/fHos8M3Qy/Ps8+Blv6tBCVl62WqgC0a
         0cf/NA5ognbk8avb0S5nsdadfj7+dxgThg2P04Ig7eagYQ1zU9NTNpWbJ8LFhObHmAni
         /CG2wPPAcPTYl02+k3+y8p39P3RjArvOZRwaFAvkG183MdeYw9VOQFxYGWlPXZEXbmkd
         f3X+Ca9qpXCk+FqSuj/QKHlzViXfMOCf3wKPN7brAcmBf8AZc6Tjqlx6xGZSQBIy1F2t
         LmEg==
X-Google-Smtp-Source: AHgI3IarpUOFmYuEpyRHfr1TTUj3VJC5J9dXE2KcUUmtr5uYHVHSVePdSPA9VM7bLBhpyy9RGPODUQ==
X-Received: by 2002:a62:864c:: with SMTP id x73mr17991591pfd.49.1551064667030;
        Sun, 24 Feb 2019 19:17:47 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 10sm15814929pfq.146.2019.02.24.19.17.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 24 Feb 2019 19:17:46 -0800 (PST)
Date: Sun, 24 Feb 2019 19:17:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Mike Kravetz <mike.kravetz@oracle.com>
cc: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org, 
    akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, 
    n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, 
    kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
In-Reply-To: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
Message-ID: <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com> <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Feb 2019, Mike Kravetz wrote:

> > User can change a node specific hugetlb count. i.e.
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
> > the calculated value of count is a total number of huge pages. It could
> > be overflow when a user entering a crazy high value. If so, the total
> > number of huge pages could be a small value which is not user expect.
> > We can simply fix it by setting count to ULONG_MAX, then it goes on. This
> > may be more in line with user's intention of allocating as many huge pages
> > as possible.
> > 
> > Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> 
> Thank you.
> 
> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> > ---
> >  mm/hugetlb.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index afef616..6688894 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2423,7 +2423,14 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
> >  		 * per node hstate attribute: adjust count to global,
> >  		 * but restrict alloc/free to the specified node.
> >  		 */
> > +		unsigned long old_count = count;
> >  		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> > +		/*
> > +		 * If user specified count causes overflow, set to
> > +		 * largest possible value.
> > +		 */
> > +		if (count < old_count)
> > +			count = ULONG_MAX;
> >  		init_nodemask_of_node(nodes_allowed, nid);
> >  	} else
> >  		nodes_allowed = &node_states[N_MEMORY];
> > 

Looks like this fixes the overflow issue, but isn't there already a 
possible underflow since we don't hold hugetlb_lock?  Even if 
count == 0, what prevents h->nr_huge_pages_node[nid] being greater than 
h->nr_huge_pages here?  I think the per hstate values need to be read with 
READ_ONCE() and stored on the stack to do any sane bounds checking.

