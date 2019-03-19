Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8D79C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BFC320693
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:02:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="cEUH3Lqw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BFC320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 384CE6B0005; Tue, 19 Mar 2019 15:02:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 331636B0006; Tue, 19 Mar 2019 15:02:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D2336B0007; Tue, 19 Mar 2019 15:02:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2AEF6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:02:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 134so23705930pfx.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:02:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=NZoJbC8WOTr0NdLPHDxUPPIt9/DJYfgztYt8n26Np0U=;
        b=JK++3nWthgG+EU73Qb8DYcWvF/2tFUyzHAq8H8tdj8lfRa200xCDtK56VEQW0dRv1q
         n1i4iPbcq75IuDigjobbOlAI4Jt1szgH6O4x3zYgf/gOy3nhv0DBy6J4xnQxg4L5dp0X
         lqNvDDwQfyRUKo0nzOaMbK8RN5Lf23vJZb9tzJ5rp1aU+TD9wp1lekvpoXQf92oOBhZV
         77Fkl7bMRPEWNQ+tC8UwZ1R2TJeiBGz8MKkh0uUc1l09wnf+wCjQMsQc8huHOIdLG/Fv
         OvD6RFNHGF/USEfTaC2eki7n8RmqkXjDolZ2R7/dZq8tzLn8XlATCpAsYGROM0FJ/TfY
         8hbQ==
X-Gm-Message-State: APjAAAV/ChWn2NkXHA+Usu6PobnTyJ0r3K9WsmK4LZ++ONZyU6QfHn8c
	2lJI2PVLZvNobzqcsMLjr2sQwuGx1BxnytmJEwS4gvugGjwY617TKdALrxS5OxcUny5FLm69/te
	exraJgZP5kXVE8nkdAJhNs5gyc83iBJTbjXVToWm58PLMBgLY+kNkpSfrIJPzH8U5FQ==
X-Received: by 2002:a65:4147:: with SMTP id x7mr3252044pgp.54.1553022155283;
        Tue, 19 Mar 2019 12:02:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykDPGmwwYbCyW3lqC5G8OGsG3cu64n8vQH8qUrwLH00Rb141BJs8mfB5T1Ae6CzTuYYEcN
X-Received: by 2002:a65:4147:: with SMTP id x7mr3251879pgp.54.1553022153568;
        Tue, 19 Mar 2019 12:02:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553022153; cv=none;
        d=google.com; s=arc-20160816;
        b=NBF8JzolkVMHJPM0RWFNhE86y1nCe3++1ha8gfmCII+43czWPnEYMWzuKQoX41+aCm
         q63VEB6gY9WCDNoal5OPFhx1Ga8u5wPb1LoxVNXNAwwLXVgEnlF0qY3Uua694FFSNGoa
         4qSBB0MRELWbh781HUpH7oLikURflNAnjONHJ/dqBo7GZxP+dDGLFcp8kpV+1eIXe5eV
         JdR01VEeZvwBt1N0CQdFDFNWQhAztiyKRRpQBRL/6WbEcPg1kSyr619lzSGD3v8BaxZI
         Ua7JQ4fubs5RQl1OVSxv5iyhcSGu5M6cF/whTg9QcuUtHLps/gFSox3K8lZ1o8CT5d7/
         KJ+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=NZoJbC8WOTr0NdLPHDxUPPIt9/DJYfgztYt8n26Np0U=;
        b=FNfw6j4vhhk+/KjnS8HNbRbh/ITVY0soLUHan5fDPD6Hxw7ukfj9/TnzY3Tt/l8oXw
         R414+L1ICJYDJLXimldsWMUYGAElYS2MNs0vq9FYIY1IQHThTqQDQfwDucp02BFexzBQ
         +kM2tz25wNTOoJgT2BfTMnuIU2NQ5dldeQDdqnk5OxY86nq+N+kJrslPt83YDGmFaSDA
         fMiCIgAgi7z8N4gYZsmgbkQKoRiDDnPDhAGs9gXgCdDY+RAEpgF/aSfcGhDcgSkofKdK
         ErhRrFCswZaqanRz+0tg6PL6KV4GAq6KDdOpRBI0Ew8EejA3oHa2LvrfpmSx1C1y+CEF
         8DWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cEUH3Lqw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j134si12523214pgc.42.2019.03.19.12.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:02:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cEUH3Lqw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c913cb90000>; Tue, 19 Mar 2019 12:02:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 12:02:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 19 Mar 2019 12:02:33 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 19 Mar
 2019 19:02:32 +0000
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Jerome Glisse <jglisse@redhat.com>, <john.hubbard@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe
	<jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com> <20190319141416.GA3879@redhat.com>
 <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
 <20190319153644.GB26099@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <99882bf1-1db8-fd2c-cc72-2a6ea8ea4f89@nvidia.com>
Date: Tue, 19 Mar 2019 12:02:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319153644.GB26099@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553022138; bh=NZoJbC8WOTr0NdLPHDxUPPIt9/DJYfgztYt8n26Np0U=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=cEUH3Lqw9UBui8Fl9HmBEvNVfx73iPEdZqVl+LLKqXgHVwB0VcSbDy385l75xJqu5
	 331YZ/UQtFcSBuZnrKiQz6kQOIs07Y/L9OVI0ot2hjFtbEzxLPlHH6RHrAxg5oRzHy
	 7jnl03iZU4oMHJiDR4HmuuR04+8nBrMtK1y4qb3b38mhnm4ZNsfBH9v88Pw5q+3XHh
	 1L4YW/u593GRa+5uQQo71uYfBXVoLojpt+lxUXMJKnsIY9pWVT/vLyfF57No+6qBeJ
	 RUvCPIT0OiytlsDBsz/EGmWiyI2RDo/55GN4obyJ++mj4Ll3E8oWcXLEgy2jbDWpZd
	 8AHmcW7zcs33g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 8:36 AM, Jan Kara wrote:
> On Tue 19-03-19 17:29:18, Kirill A. Shutemov wrote:
>> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
>>> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
>>>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>>>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>> [...]
>>> Forgot to mention one thing, we had a discussion with Andrea and Jan
>>> about set_page_dirty() and Andrea had the good idea of maybe doing
>>> the set_page_dirty() at GUP time (when GUP with write) not when the
>>> GUP user calls put_page(). We can do that by setting the dirty bit
>>> in the pte for instance. They are few bonus of doing things that way:
>>>     - amortize the cost of calling set_page_dirty() (ie one call for
>>>       GUP and page_mkclean()
>>>     - it is always safe to do so at GUP time (ie the pte has write
>>>       permission and thus the page is in correct state)
>>>     - safe from truncate race
>>>     - no need to ever lock the page
>>>
>>> Extra bonus from my point of view, it simplify thing for my generic
>>> page protection patchset (KSM for file back page).
>>>
>>> So maybe we should explore that ? It would also be a lot less code.
>>
>> Yes, please. It sounds more sensible to me to dirty the page on get, not
>> on put.
> 
> I fully agree this is a desirable final state of affairs. And with changes
> to how we treat pinned pages during writeback there won't have to be any
> explicit dirtying at all in the end because the page is guaranteed to be
> dirty after a write page fault and pin would make sure it stays dirty until
> unpinned. However initially I want the helpers to be as close to code they
> are replacing as possible. Because it will be hard to catch all the bugs
> due to driver conversions even in that situation. So I still think that
> these helpers as they are a good first step. Then we need to convert
> GUP users to use them and then it is much easier to modify the behavior
> since it is no longer opencoded in two hudred or how many places...
> 
> 								Honza

In fact, we had this very same question come up last month [1]: I was also
wondering if we should just jump directly to the final step, and not
do the dirtying call, but it is true that during the conversion process,
(which effectively wraps put_page(), without changing anything else),
it's safer to avoid changing things. 

The whole system is fragile because it's running something that has some 
latent bugs in this area, so probably best to do it the way Jan says, and 
avoid causing any new instances of reproducing this problem, even though 
there is a bit more churn involved.


[1] https://lore.kernel.org/r/20190205112107.GB3872@quack2.suse.cz

thanks,
-- 
John Hubbard
NVIDIA

