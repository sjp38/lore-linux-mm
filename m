Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23262C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:15:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFA202082F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:15:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFA202082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 713288E0002; Tue, 29 Jan 2019 09:15:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698A08E0001; Tue, 29 Jan 2019 09:15:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53B058E0002; Tue, 29 Jan 2019 09:15:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8318E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:15:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so7961973edd.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:15:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uRjSD5ChJzff7/0g7ltLNPDnjDKlfU4lpU7KI5PoD/c=;
        b=cRlbMHJRgTZc83og6tvN5RnTAkGLMiSD8ggz9FCXW37cpaJgRWModMvd83tC/Qsn9B
         cC3eOzkHTgooMinh5FBGvowTzMrFTHLRKTrdPeYugW5A6ZNrR1hfGia5cNHVwyzZy58S
         FLgdqR26p7W1AuwpvvKSsP9hengz1RvImtY17CSxF6DM4eNmNfGiXwk0qPM/0udLJysp
         hHqidfpZPdlBzU88DzWTDWq/Z6eD2FYc6HTHPRCROgu5lVV0WKVaBipgxMEzIDia+BBH
         wm/goFQLOsbEx30tEW+rvAkHCM4tRc2e3+e0aKtX59nOCeC6SkWb6xT1e/Mlut0RLC3A
         GGag==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AJcUuke9+HBQMhXDTveydIoGZp5IA2T9QPgUaI9siyysKWXNFTCZG6fQ
	leBLOUCn2UjAhGU9henoVLBsaZh6IXXuWZMNguld4HuiMFtz8iAXMvJWQ6k618d+uRtqCEu5kOA
	ZugPh98TwOGqQh7jAPs4/HA081vmMk3yAfbG96kLm1uYnbTOMQFhhlk9/cAG8cQ8=
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr25385523edh.46.1548771305600;
        Tue, 29 Jan 2019 06:15:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5phRLzWnbJqmE7JblRl3ZDZZpjxgZ166sp3dmrVjMVJrrRW8YjZzd/retYBammoUw2uV21
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr25385470edh.46.1548771304752;
        Tue, 29 Jan 2019 06:15:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548771304; cv=none;
        d=google.com; s=arc-20160816;
        b=PX2a3Zzh/SfPkMTaSh/vcgyvQuk/0uvkTxeyNshI8mUU6X/Q7k8NNgUWGK9VmChEXk
         a74nPMy4PeF0RFA3p9doD1P6qw7EtI9wCapo8WrjOMJds6ExxjxW4j0Exshy/r2umpNc
         V2l//8nlONq7pwEbRFnkI3v911zSyajt6Kt5GvY62R69d+TnYU1nboC+1lu6pVYgdCL/
         jcWHbBpqb9U5afRlSM1t0FZQVriHJmrKrNd3+uskzvXAbkHInei46S6B+hEKmAtgXcQa
         GVTZyDKysXCv+AGNtAeaAE5usBZHNkiWyKGSxs3Dbu4YwsnUmaA4+kmAjY7Gc+n7lKPh
         O5kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=uRjSD5ChJzff7/0g7ltLNPDnjDKlfU4lpU7KI5PoD/c=;
        b=Ei/44/Dlxj/Z/F1D5r/KS2mG1t/wgXU22/mf0ylehH4NCx1+5RgOttCMCeROa6YUEZ
         kj7BOUK/IqDTIDys0F/thn2EH1Ykr9y2cPw9OvZBz+9UDqy2J+mXEX8F85iNzbb9wJwy
         7VQOoAZB6tuR7x6mJkT+rr8J9ngKPwOYDd8lp5Y/zXNFwzJwWzm1+NsM29Az35htyxNm
         jZV1zzDVqz4mrHLzcD9HJRCJfNQ4iz1HdUq7G1uDRmXYVBbgL8ZPe+HqePrDJLxRlCMd
         Q+RGDb55h3bPo36V+Tc9tOjLJTaJhaNQMY6EhkXpKxPQv88q9HRMoMBlMkAY13Vb/h7B
         qX5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s24si1519111ejb.100.2019.01.29.06.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 06:15:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0EEA4AE72;
	Tue, 29 Jan 2019 14:15:04 +0000 (UTC)
Date: Tue, 29 Jan 2019 06:14:45 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jack@suse.de,
	ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, dennis.dalessandro@intel.com,
	mike.marciniszyn@intel.com, Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190129141445.kch4jxr2ps62ohcw@linux-r8p5>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>, akpm@linux-foundation.org,
	dledford@redhat.com, jack@suse.de, ira.weiny@intel.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, dennis.dalessandro@intel.com,
	mike.marciniszyn@intel.com, Davidlohr Bueso <dbueso@suse.de>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
 <20190128233140.GA12530@ziepe.ca>
 <20190129044607.GL25106@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190129044607.GL25106@ziepe.ca>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019, Jason Gunthorpe wrote:

>.. and I'm looking at some of the other conversions here.. *most
>likely* any caller that is manipulating rlimit for get_user_pages
>should really be calling get_user_pages_longterm, so they should not
>be converted to use _fast?

Yeah this was something that crossed my mind could come up when I
first sent the series. I'll send a v3 where I leave the gup() calls
alone for rdma drivers; and we can at least convert the mmap_sem to
reader.

Thanks,
Davidlohr

