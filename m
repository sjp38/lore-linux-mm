Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58C91C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 17:14:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBF882087C
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 17:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="fNHfgZqQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBF882087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BBE78E004B; Mon,  4 Feb 2019 12:14:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46BA88E001C; Mon,  4 Feb 2019 12:14:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 359D58E004B; Mon,  4 Feb 2019 12:14:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D82F8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 12:14:21 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b6so565280qkg.4
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 09:14:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=rRIYgpkoOU9OXyNN7jqzPWMWewZIFQicQrnhsy101kA=;
        b=tzxP1XTlR4D60g/wUNrbpyRtgHrjArFP8m9mTQBolzrXKKZxoxdcpT8GljrZD/SJqD
         YD1b9w3yJH1cTycVCKBkajWL6H7sMTTxFQNROhkR40XzLpqcQQlrrTIcdRPGBmDBnlYn
         ucQ6m7rWiCitCFUonia9g4Ggyb49QOdN9Hhno5unrXf45+A7ZWDvf2S0yZPaoj2EP8/8
         LYLg6xqu/WT/2qvKam3oJ5o6ikxo4WLwLJEIwNL3BB+ZqfV8fmD79LU2ym8llsX1JjDF
         v8h/ikROhFeBAojEdYFms5qg5oSDWOW6pg6KMriKELOMUifJnlo5KnsfjTwX3GJmRepC
         GC5w==
X-Gm-Message-State: AHQUAubHhsHDnN0E2A7sa758ehf+bO0OoFkVdnPa3AifCdBA0ob3H1ei
	+6LXWTruwnX8sgl0M8EOYhipZgmORtq/ZkaGdfklbfjx99cuvCB+JRLEtIZijckS6FMxx30yVdt
	QQ50j/vW77Wf/Gbhudo0aWg+XfGT6NWLLwn0/goMRd2YItTT4bSQyHtO9whiSADA=
X-Received: by 2002:a0c:cb85:: with SMTP id p5mr354475qvk.162.1549300460825;
        Mon, 04 Feb 2019 09:14:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia431TyxHhA7sHJthN6XBhD64zeaqsz6olHYhBuNZaQTE68XRm8+PVsCRGKhQAz2yXLIRbS
X-Received: by 2002:a0c:cb85:: with SMTP id p5mr354430qvk.162.1549300460191;
        Mon, 04 Feb 2019 09:14:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549300460; cv=none;
        d=google.com; s=arc-20160816;
        b=XCNf06f4DPdtiGcc8Vvhdl/JieHz56mHLW7ZqFCgS38j3wi5PTVmg0nDEgjLTpDoqr
         bvDwagTqxGqhtA/4U+hWfzJRBt8q+MoBg9eLOw5E5upxypMVSA+6N2THOqWoU7P9DGnp
         ex/Z0FcdCJSGsfKn8SOYIg2LSyU+5Bn5M6Hac9Qr1Lu0lk7JjoWEcc3BcPX8kWDWa7Jm
         h/jghzXfek5tiEVB1sr2JaBY2Ji06hczJ3oHgAr82oHEBsziCfmPPiQ0pp9oSVKOKFc3
         o11n3orBHK55srfkQ+o9sBPKu0+YhlXD0+1HUfs+nhsb4OYD8yRQTuVTPrdHPQ+jBkY2
         5P8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=rRIYgpkoOU9OXyNN7jqzPWMWewZIFQicQrnhsy101kA=;
        b=aaIzUea8hP8CxE+Id5YrB9owyP1CFWd49ITyl2qAueAb4t0M6EeY0gnMw23qCZ+zq4
         Fh7KJZqZqiPeXNQmUuF7XF1LPx5y2+SA1ixFsvowMLLqCUc0ciXKD2qi2Ogd9z+vXhY6
         oHQVtrwJ3ScsSW9rip/hR6dnNlerKYu5MW5Vrc0BHuiDYpZmh7xooxvYBnOBrwcWvs8y
         3kdWRKa8TswcvVv4hyuGl+kCx+FCHo7MZq3p4qfcDelbX97YF85p9NtUaq15BNDU8M5p
         tjyPmHn42GaVYdehJW80TrfN8VKzFxsgSFlEwq4iFnym48Mj91mBD2Axq9W2S2JwIyei
         nrSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=fNHfgZqQ;
       spf=pass (google.com: domain of 01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id 40si4482322qvu.207.2019.02.04.09.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 09:14:20 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=fNHfgZqQ;
       spf=pass (google.com: domain of 01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549300459;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=rRIYgpkoOU9OXyNN7jqzPWMWewZIFQicQrnhsy101kA=;
	b=fNHfgZqQCAIPedvEn9/V09tGYqNz+41uFUDzEvPKPtLzF+oYs+UPyt9aF1iKxinD
	bh8DOvBrneM8djIV8FXwYLhmyfi1OX1or69dkUp1EME8XHHZE50Sl5/y2eNyzaDG0p9
	sgutHg/yTiJ/yAYnzb5sp8+EcpQzIQIv6gS10zzU=
Date: Mon, 4 Feb 2019 17:14:19 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: john.hubbard@gmail.com
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
In-Reply-To: <20190204052135.25784-1-jhubbard@nvidia.com>
Message-ID: <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.04-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Frankly I still think this does not solve anything.

Concurrent write access from two sources to a single page is simply wrong.
You cannot make this right by allowing long term RDMA pins in a filesystem
and thus the filesystem can never update part of its files on disk.

Can we just disable RDMA to regular filesystems? Regular filesystems
should have full control of the write back and dirty status of their
pages.

Special filesystems that do not actually do write back (like hugetlbfs),
mmaped raw device files and anonymous allocations are fine.

