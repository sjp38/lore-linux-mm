Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48448C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0538B2186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="giZRZAzk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0538B2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE718E00DB; Wed,  6 Feb 2019 12:31:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AE0D8E00D9; Wed,  6 Feb 2019 12:31:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89E1F8E00DB; Wed,  6 Feb 2019 12:31:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 456EC8E00D9
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:31:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so5711061pfk.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:31:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=M7ZESgA117Kl6LnfeqS2MCqLt1s/mI0gTcjYckq38ug=;
        b=OnPGe9wyazRU356q+G0/jx5Yyd5HL+Gm6hNCXcZ+ioqT6Z7mJjICSaEfeha+Ymrsrz
         ipkrzGAC1DCrm5IsXfpsz30H+YeHtIJ+G4N7Lbhl1wxdXO6ML9ZkWT1wmQn5uupHb+hB
         nbkJzCAPIo5YOqFS3CWJYWTVdxc2gLGiqBpiPlt18Dddp9Ovq/8vqcYuPlhowxIsbCp6
         NwvQlP/fkKdQb8b/+yjO5nEnORfrpWq4lazfPPmKAGru9EeveJFjAJq2IngkT0hK3hob
         n7mkRRUWOVlx0P24eThESA2d3HF8bkgWi3fVtNhSW+DXmITqvtAMUlTG+oyfC8IeADon
         lHFw==
X-Gm-Message-State: AHQUAuYnShCsbqe1jQZWKqb/QPT4NKH49NJUDiXjjXQEit1YzNqKQ7Gk
	A81mY9ik4Bvi8eS2R30w0ErAkh7uX043TTi2iKUZpaLzKdkjkPc7l5Ey07K0lsMQuGaxjmzJJtf
	5GuupfVHOBTNTUQ9FMZZZPDzfaKPKzoDAvZ6zIztrnxKm/1KQ1tgCoKnaurFH435IJTG6Hvsk+K
	K5uBPlHW8iH3XO7HAQicAvFwZgcPRfBqNn2Zc+BLdKiVbQnztgmzxMPvFPOekmLW+3o/WKnaMAN
	rGA2sQi+MUljnkplN/usa5KntVYp4iXi+l0EgeL38KKK+dpqNihNXS6jV6CiZK+9hPVbZ39mrfS
	4gKsm9hXv/1Cc12yoPE9m61l6adL75Ajyh5CFu+8YfXr97yBzGVHlmRrZwVJdUIJVwhAxHUnFhp
	k
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr11618276plv.43.1549474278900;
        Wed, 06 Feb 2019 09:31:18 -0800 (PST)
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr11618216plv.43.1549474278212;
        Wed, 06 Feb 2019 09:31:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549474278; cv=none;
        d=google.com; s=arc-20160816;
        b=dN6bUNgSoNYznisGt1wmRFUx67m5zCR9Cw7k0VbwUVxBk3/g5DjLA8h/3HtysDF4a4
         y4Od04EWlN6cM18+ecYBtWS4y8r0TpPnCjcs42vw7+Wo0YIjU9wXqWVoFaG8gS2Gki0M
         olMU63CnJeF5aCEaT8O1Qiorm5vmAbaM3o2nzgewvIb6D7yg8lDKFucwivCLQBQF1XX5
         MLz7qihDjALsyMAbsFF+UU6qGcu1iMsyFmzQ6LE+2qZqWjx+jjor82Sc5DS1zoNQtccl
         QRGHvfFYHKZFAEUKS5wocJ6wB/V7/i5eVSkvDXYYHDaJFq8q/G8MeRmNVqvSk822e3fF
         7Kgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=M7ZESgA117Kl6LnfeqS2MCqLt1s/mI0gTcjYckq38ug=;
        b=ue89GueRJ1yXAWtLGiTQxtutCnTfw74fD3lNvMA3evuia714YIgDtUseDkb5p4nxRh
         yK9phzjf2s8gUqy48UMfuTR2fouHfBB5UTBuzYmE2TKui8fd1iBD4n3t/RmAingcYYxn
         at0eZpYUZJ2wYMwkF0gkeRi0/MS9pbTp4kZLiwa95zAdzV7ucKgSsD9NhVxCICsa0NjE
         ZARN+FMyfleJGztW+324djGkOUWJFc+q2zT6b2KSMPQ/x8bbkzEi7Pp0x4mzMrg7FOh+
         AAm5uO5D6NZ2FT8wUAv272Y23puX5huGzvH8ivAXwvDSp+M9k0x+p/OckBCkCQ/s4lKW
         a5Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=giZRZAzk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y17sor10132276pll.68.2019.02.06.09.31.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 09:31:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=giZRZAzk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=M7ZESgA117Kl6LnfeqS2MCqLt1s/mI0gTcjYckq38ug=;
        b=giZRZAzkmkBVhWAM/uex9MysvKvmQpTztwKM934OeE1o/Q7yWdaLaCT6lguXWRg+ZU
         dghk+jIylKwaKSON158y74S80W1v/+3yT8yJ+nwSPDTVqkR/AysyVUc60XyNcsDkIWhb
         nCq7NLI6EkXzNIXqLz7LxxgLg6pA/r+Zho4Wv0N3jN/mGs4Yf4OgiTDkBamT9bGzonup
         F01e85T0DM+FsQPHGLZ97HGEDnXEQeox4Z0txw11pAy0qwEJ75FT+q+C3znRJgfmBq1S
         7JWd+Myu3MSWS2UbuYGZ6rA4sHQQhZeKWkWONJoLxl0zmjiGnd+BnuD4ApXWZQ5Qm/CE
         z2CQ==
X-Google-Smtp-Source: AHgI3IZ124Xx0Cv7NJbPpRtVN9SOU/LG8DcJ+7oWMiz0MTcLVc/s2Ua3HZpgbB4LTQuLG6XqjooUwA==
X-Received: by 2002:a17:902:7882:: with SMTP id q2mr12090872pll.305.1549474277444;
        Wed, 06 Feb 2019 09:31:17 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id d11sm8242868pgi.25.2019.02.06.09.31.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 09:31:16 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grR2Y-0003x0-U1; Wed, 06 Feb 2019 10:31:14 -0700
Date: Wed, 6 Feb 2019 10:31:14 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206173114.GB12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206095000.GA12006@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:50:00AM +0100, Jan Kara wrote:

> MM/FS asks for lease to be revoked. The revoke handler agrees with the
> other side on cancelling RDMA or whatever and drops the page pins. 

This takes a trip through userspace since the communication protocol
is entirely managed in userspace.

Most existing communication protocols don't have a 'cancel operation'.

> Now I understand there can be HW / communication failures etc. in
> which case the driver could either block waiting or make sure future
> IO will fail and drop the pins. 

We can always rip things away from the userspace.. However..

> But under normal conditions there should be a way to revoke the
> access. And if the HW/driver cannot support this, then don't let it
> anywhere near DAX filesystem.

I think the general observation is that people who want to do DAX &
RDMA want it to actually work, without data corruption, random process
kills or random communication failures.

Really, few users would actually want to run in a system where revoke
can be triggered.

So.. how can the FS/MM side provide a guarantee to the user that
revoke won't happen under a certain system design?

Jason

