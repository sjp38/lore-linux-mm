Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19471C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:52:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC3D42084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:52:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC3D42084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 715E58E0002; Thu, 20 Jun 2019 10:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C4EA8E0001; Thu, 20 Jun 2019 10:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58D9E8E0002; Thu, 20 Jun 2019 10:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0F18E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:52:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so4616235edr.7
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:52:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SIcMrLziZYUEFo0cQhEbQEjSkt9HMxe+L6BtX2iDmxY=;
        b=rRhvEuSrl2Tkp2Dn9heDFAuxS2zY25mtiKpdlLUFZzx4B5bbA2e2ssQcU8a8Voehxv
         vTVTgBNAf42Zf12YmagSLgeCwNSAO2FPD1c553NvzO5ghm6w1fFLMj8sUwjY8DZUhvlX
         esPVST9p8oyOJUNpJIFQAwJd/MMiPY61C8PyGyCFvrYxyIdg/67eFJW2aQsUJS2LX1ZH
         XLW/oC/ufOYE6pXIqL2g8DMt+1Qju8hzfs5WzoWh0hFhDTxuHFwvL3SQQXy6jZbq1vq7
         oRD9RG9UQuRxGMx/xYbh1VAVlGq/XwQfS77BFsezLCZ3zPA7VkTyM0AkX/r1xtvOv6sy
         jkbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAX7/mpMvlAolO65kjV6G/mqtjxU8blPst4D+0Ngwq50QaECHEy0
	K4dBTx3UtjrCX6Wqo293vyOvyD1Fk/ezxuStbivMHetfQUJD1nUhIdS38IIpS4oZNqBOmwxoKym
	05Jvs+2E9sqWnBlD0gTVVouVoD7/zN1NRoJZDNSKVJUhRrk3ccKxMUQAP5ru9eF0elA==
X-Received: by 2002:a50:ac12:: with SMTP id v18mr115072811edc.232.1561042376632;
        Thu, 20 Jun 2019 07:52:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+qFrpQl2uuyNXfFYwQIaFIQ0I9/675jzZpT1Ecoo3kZ5vCCPfYhJEYPNuauS/zqAlCE5H
X-Received: by 2002:a50:ac12:: with SMTP id v18mr115072733edc.232.1561042375869;
        Thu, 20 Jun 2019 07:52:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561042375; cv=none;
        d=google.com; s=arc-20160816;
        b=PzLXf/xmZoM2eL2pgQ/tvQLlg/M2JtA3y0jp640IHhjjWDcPQaalNQqztaIZCBmPBT
         iowweg24jTdv29sW1zl56y8UFFayJQS6SPdKvcuiNIt0B27xnaGarh5AgpCRIZIiRKkw
         tp8H8EaRr4waO7h4WVjatA6FclAifLqa5CnV7pmK0FL6wWt/cRQxIujydaZ3910PgPKD
         8uflsOZ1dL5aAUDqwYkNNXbEss1/x2gUWv2M62dOdZ/zmYHINTM90TfHdkEQz14viNvg
         6tHjT+uruUfr/FaKeJARXX8TTAFWgXALXovPCXJqSnK58KLDo3jrPi9ajenzXvdPPw8y
         dPiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SIcMrLziZYUEFo0cQhEbQEjSkt9HMxe+L6BtX2iDmxY=;
        b=CQA79krpOfEM4Di/BPXpwCD0HvLuuwLhn+PyPZtouEzo0rjSzXT06A+nC8vqN/3Z85
         L1SQNiVAUZmts59z5X6sQeHUZmMRT1viRKlI2inovzj1z1oMWtR1NlcPTR64dIMAs0k2
         Q3G8ppnH3bwhla8+ew8vnRRwuv7ASHhJ2li9ubrEnZml8v3rkeWkgWTOkVuczlMxlca2
         1aFxIIKK81+b43v5xLgUENvPZMkwAB4QoLwz6vBayRhyIUJxYXtVA5NyrNd2UluxPfVp
         VXyAjTgVHEFhDHRh4RpnYYj9zw+yDjrj/A831MLYwGQAFK7m3SPmnPkUAiU+XTtCUrCf
         41Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oz1si2483346ejb.108.2019.06.20.07.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 07:52:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 327B0AE32;
	Thu, 20 Jun 2019 14:52:55 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id AF6F01E434F; Thu, 20 Jun 2019 16:52:54 +0200 (CEST)
Date: Thu, 20 Jun 2019 16:52:54 +0200
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190620145254.GJ30243@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613152755.GI32656@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 08:27:55, Matthew Wilcox wrote:
> On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > e.g. Process A has an exclusive layout lease on file F. It does an
> > IO to file F. The filesystem IO path checks that Process A owns the
> > lease on the file and so skips straight through layout breaking
> > because it owns the lease and is allowed to modify the layout. It
> > then takes the inode metadata locks to allocate new space and write
> > new data.
> > 
> > Process B now tries to write to file F. The FS checks whether
> > Process B owns a layout lease on file F. It doesn't, so then it
> > tries to break the layout lease so the IO can proceed. The layout
> > breaking code sees that process A has an exclusive layout lease
> > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > break the lease and so the IO fails with -ETXTBSY.
> 
> This description doesn't match the behaviour that RDMA wants either.
> Even if Process A has a lease on the file, an IO from Process A which
> results in blocks being freed from the file is going to result in the
> RDMA device being able to write to blocks which are now freed (and
> potentially reallocated to another file).

I think you're partially wrong here. You are correct that the lease won't
stop process A from doing truncate on the file. *But* there are still page
pins in existence so truncate will block on waiting for these pins to go
away (after all this is a protection that guards all short-term page pin
users). So there is no problem with blocks being freed under the RDMA app.
Yes, the app will effectively deadlock and sysadmin has to kill it. IMO an
acceptable answer for doing something stupid and unsupportable...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

