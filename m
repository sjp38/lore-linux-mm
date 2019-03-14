Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1632CC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:30:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C50F52085A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:30:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C50F52085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8FC8E0005; Thu, 14 Mar 2019 09:30:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 560688E0001; Thu, 14 Mar 2019 09:30:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 401678E0005; Thu, 14 Mar 2019 09:30:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0BB08E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:30:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t13so2430143edw.13
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NQLxft4Nn0PdCKNcyLYEj+4RiCbYOpGqFUosRxIuhdU=;
        b=nkZ/1LeskPj1zSQmivGqOIjinyGAoIjnYEHo72IcPLyc9FUcsqLXs1Poac5ySl4l31
         ewuYPe9G2PJEoONRozpTLcJAzyGIvUiAFD+gwGNUx6M+scy9UukPHPGzFDiRLv9dohkW
         Q86P2HYc0IF2uLuIRlMrwVOEAhPcuGdsprX51zORTVOsGTpk9o19Mh8U+mwJDXdyXzbo
         KcmAoFRvDvZZKuMlx0u1vEsyeKupdWEFWWgYuKXwkvroaYa0pZR3BoGXiZYLI1qE+XjT
         D56Ud5Kp2AlA8UVdxc73WTT4ZwhcgVMF27dKIqqwaWUY/eV2QMPJIjqJbRoFsCAshL35
         SVeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWVe5pjn11COPu3MqQBdvfjm6bFK8ArWQehcUZ6XSfuSCcD/8mY
	nOdo8S6B2Q7JCmc1VetIndbqoQrDn2NqGQvgYFx3ni0qhZUW7mhdTurmJV7dQ1dH72TGGAjAEpy
	f949kafApXLj186SvEWnaD0KaqkQ3qW210eBioHMj+JVUXEwJkYIw/Hp11jMnZwMl4A==
X-Received: by 2002:a17:906:4688:: with SMTP id a8mr20474704ejr.246.1552570241402;
        Thu, 14 Mar 2019 06:30:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXpOTOe8UK3vWFddfO/T5yp7YWzhW+Pp0pO3a0oIfWm30MpJ7DNwBKlKKAWoyH1a5gL5pI
X-Received: by 2002:a17:906:4688:: with SMTP id a8mr20474655ejr.246.1552570240453;
        Thu, 14 Mar 2019 06:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552570240; cv=none;
        d=google.com; s=arc-20160816;
        b=y8fvV3SCNySJtdGZ+rsOVkdAJT6KDAJDEeKCuND/RFnKmgLUvmlben9dcrRoOgwIxn
         FzymQwomiKfOiCf4vWoPWE5q/MTxP4NYQMqN5N0dV2aX8RK1EHxubFYW53iHcSTSu0qG
         MEgqPSInC0/z0DqPgxeRTVisCURuNRWfodiiU4ry+6OsizSyw0SPiuW69EX9dwH9yHpB
         E+YPfHsqfKubCQxXvYjRL7yM5UsPaftKK+qk92eSZBDj3DxiOCVaQ2IW+1WcA1BeLbsR
         RUHUQXweq6dGChTQIXtaqljFElraFec8PBn+kfNwg6G1CQtFo4s/fSt0VcjL4iCbF8Ig
         SVrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NQLxft4Nn0PdCKNcyLYEj+4RiCbYOpGqFUosRxIuhdU=;
        b=eWmXwhICeRL01MJcPuTZvgKa3i4qjx4tkKo6iCKnu/JZWCgyxd4jyk9nW5hmwBa/FW
         faKDXgxYpQAdK5GCqwwG6I0adPBBLEZhhM0iKqC0cq/fQAMmuw9/DTOvCKgy1MaS4xqz
         OupQPJu4aAuxQlRq8CgLICR9xjkh1zy9ABgf9BOLqObiJFnVgAqzrpTTWWtzqpGp6w3G
         aRLimGw3YhIvmVyh/Kz5lUUFimLb2z0E65POaJnQM5wqRLmJJ/DIfC8KsdiPwkkXBxlg
         KP1ArV8rfcxuNvzatoXmBpkQw5BEFqVO18HBCjUftTh6Z4FU7YDTlYwZmMXoDKV4iGdO
         FpUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si1009498edu.115.2019.03.14.06.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E7ACAFF9;
	Thu, 14 Mar 2019 13:30:39 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id A65B71E3FE8; Thu, 14 Mar 2019 14:30:38 +0100 (CET)
Date: Thu, 14 Mar 2019 14:30:38 +0100
From: Jan Kara <jack@suse.cz>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>,
	Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190314133038.GJ16658@quack2.suse.cz>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
 <20190314090345.GB16658@quack2.suse.cz>
 <20190314125718.GO20037@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314125718.GO20037@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 09:57:18, Jason Gunthorpe wrote:
> On Thu, Mar 14, 2019 at 10:03:45AM +0100, Jan Kara wrote:
> > On Wed 13-03-19 19:16:51, Christopher Lameter wrote:
> > > On Tue, 12 Mar 2019, Jerome Glisse wrote:
> > > 
> > > > > > This has been discuss extensively already. GUP usage is now widespread in
> > > > > > multiple drivers, removing that would regress userspace ie break existing
> > > > > > application. We all know what the rules for that is.
> > > 
> > > You are still misstating the issue. In RDMA land GUP is widely used for
> > > anonyous memory and memory based filesystems. *Not* for real filesystems.
> > 
> > Maybe in your RDMA land. But there are apparently other users which do use
> > mmap of a file on normal filesystem (e.g. ext4) as a buffer for DMA
> > (Infiniband does not prohibit this if nothing else, video capture devices
> > also use very similar pattern of gup-ing pages and using them as video
> > buffers). And these users are reporting occasional kernel crashes. That's
> > how this whole effort started. Sadly the DMA to file mmap is working good
> > enough that people started using it so at this point we cannot just tell:
> > Sorry it was a mistake to allow this, just rewrite your applications.
> 
> This is where we are in RDMA too.. People are trying it and the ones
> that do enough load testing find their kernel OOPs
> 
> So it is not clear at all if this has graduated to a real use, or just
> an experiment. Perhaps there are some system configurations that don't
> trigger crashes..

Well I have some crash reports couple years old and they are not from QA
departments. So I'm pretty confident there are real users that use this in
production... and just reboot their machine in case it crashes.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

