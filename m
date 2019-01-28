Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACAF2C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:41:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7578120989
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:41:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7578120989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F4D48E0004; Mon, 28 Jan 2019 13:41:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CA828E0001; Mon, 28 Jan 2019 13:41:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 308B18E0004; Mon, 28 Jan 2019 13:41:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E781F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:41:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so14769167pfg.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:41:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3ggLK68jDfBVTqBqA9BSwW8+v4wYSWEcBBPFtrYTAcY=;
        b=R/2sOE+yUghwQjnLd7icB/haeeDoaW+0abLFYt6Lo5cZy4GB9rDDgI787pJ4G3X3hK
         4dxq5iFT5bc/fGNM5SZj9R/hdAll9g4sQl2Romkz+PmB3KUEYQ4QWR8fHu/WmL4KNveT
         8tCb4+2NhHadzCPAseEI+gACum2AR/wSmWD9eOY36hYPpY9vsFsgwV3kwu566q3xrZDI
         WITWKq6j+YTVL5esRDj6DNIvPdOCjbiWFGMlIFBBHDEJYx3mewiiCNExp6K2FreCohdM
         cJaarBpIrViNOcjRn/4V3VCC5HzvUzXPjqqRNj9CcK1rdMW3VpcQPK23HoKbOG9n1ETZ
         IwrQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukf9CYKUROByLZvH+q83BjX7Cf4M+X0eaRlMdwVJtQ7lBi5W3p11
	xOhjOk1Z6yVz0io1Hcj6p2zuYmYNaB/EQ9kPVpq2VAyLN78YjTilBKkOCAMverbtfN8wnAt1p60
	Mc6Q5IUo7D+SP36yZR70e3Zl5s/3+uqDMEyhpiPDafe9k56YExTSQ5qVLBZvuRU0=
X-Received: by 2002:a62:5f07:: with SMTP id t7mr22826705pfb.108.1548700903620;
        Mon, 28 Jan 2019 10:41:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7/tqPMh7cxvehOueTRSkctUcf7qOipd2Zpw8cUCzWIVvHIqi90kEt0EvFRX8HX+pXgYhVM
X-Received: by 2002:a62:5f07:: with SMTP id t7mr22826660pfb.108.1548700902712;
        Mon, 28 Jan 2019 10:41:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548700902; cv=none;
        d=google.com; s=arc-20160816;
        b=WdNnA8+3GtwhSE+PTqjtBST86MNB3ZasD9sX8flOolWLvHFEGWpY2aSmFDeIOI+zG/
         HQ5lzGC8HcGEsjKsMsRRB5EAix4Pvrke6LCLy155KEiPd9NBRMy5ibqqvzIC7saEpU9l
         NhPDL6LPa7ijrpk+tLf3asSqplii6+YF6sKNUUYHIzNTAdvwd16nmrBgpLQ7AdiA8Ett
         o3NoN9JT9sZFwrNtqYokcAKSgIcFInCMigCWgqwxxAtyLiuGWXv17cHGj0JDvQFts5H6
         Hjo/pNbMzHXPKen2uQC4evdhAB1jk116OxLsaKLecQmn946AxbStlLZQPl6EQQt6TRUA
         ME1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3ggLK68jDfBVTqBqA9BSwW8+v4wYSWEcBBPFtrYTAcY=;
        b=yaYlRoov8vDM02g91/4KmfwATKnsM9m4cbKYPlr7p0rO5e2W7dkpmWemWpTFb45lne
         u6Da7pVKpo06ddjLUhb7EeJPVpMbL3G+jGu5RZF73iUbm1h8d8ZsRb+95gh3AJDeTjXS
         3zePW4B+fUWaFzUjvNjigVgDGKs/m7eQj/JFkH9SPNQ2nv9DDx5h23dB2qOkZkJVLVYO
         5X823d9qm8GLzTdArYiTIqgDOEiGM7xWzmW7ggFzGvOH2ARpJ7q8rvyg/UgvgljGzcZJ
         gxz3yRc+hvCd0frkQPQV0R87BThROfOYRK8wt1VVLNNsvu5vOTRFcXEHQ6dA0ZW8q3FQ
         9llA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s71si33021879pfk.105.2019.01.28.10.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:41:42 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D340EB017;
	Mon, 28 Jan 2019 18:41:40 +0000 (UTC)
Date: Mon, 28 Jan 2019 19:41:39 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Message-ID: <20190128184139.GR18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128095054.4103093dec81f1c904df7929@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128095054.4103093dec81f1c904df7929@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 09:50:54, Andrew Morton wrote:
> On Mon, 28 Jan 2019 15:45:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> > have pushed back on those fixes because I believed that it is much
> > better to plug the problem at the initialization time rather than play
> > whack-a-mole all over the hotplug code and find all the places which
> > expect the full memory section to be initialized. We have ended up with
> > 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> > memory section") merged and cause a regression [2][3]. The reason is
> > that there might be memory layouts when two NUMA nodes share the same
> > memory section so the merged fix is simply incorrect.
> > 
> > In order to plug this hole we really have to be zone range aware in
> > those handlers. I have split up the original patch into two. One is
> > unchanged (patch 2) and I took a different approach for `removable'
> > crash. It would be great if Mikhail could test it still works for his
> > memory layout.
> > 
> > [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> > [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> > [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> 
> Any thoughts on which kernel version(s) need these patches?

My remark in 2830bf6f05fb still holds
    : This has alwways been problem AFAIU.  It just went unnoticed because we
    : have zeroed memmaps during allocation before f7f99100d8d9 ("mm: stop
    : zeroing memory during allocation in vmemmap") and so the above test
    : would simply skip these ranges as belonging to zone 0 or provided a
    : garbage.
    :
    : So I guess we do care for post f7f99100d8d9 kernels mostly and
    : therefore Fixes: f7f99100d8d9 ("mm: stop zeroing memory during
    : allocation in vmemmap")

But, please let's wait for the patch 1 to be confirmed to fix the issue.
-- 
Michal Hocko
SUSE Labs

