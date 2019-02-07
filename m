Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EE2BC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3AD821900
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:33:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="O6JuEwwu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3AD821900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67DA58E0019; Thu,  7 Feb 2019 00:33:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62C958E0002; Thu,  7 Feb 2019 00:33:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51C248E0019; Thu,  7 Feb 2019 00:33:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 107328E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:33:10 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g13so6660728plo.10
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:33:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1dhO9WZwCYTMt9fJvM1nNU2p7dvIM4HOJh/eYKYBoFs=;
        b=LJyK25HglcOvfc94XCWTnVhfJSL88mT1+4MoeKbpqdWOmVQt2YqIIJt36ezlPB2QWm
         oKIC7jHQAaV7Md2wCHR5XvPiit4MVaiEF8Pxov9m6b/IwoaLn6mqWtQQthyxRelDJq3I
         xXLX0PgWg+wiaFmmXVv6heJpNQ8GjcpakPcUXPPnAkeessAL/fqal8pwHxAt59flPNgl
         EYF8pyJMhGJz0aLtrybJ4Tb1XouW6/kkDl9RQnc8KKOrModq0nn5Q5e7r7JBxz9GLFO1
         qZvwSw0ssai7wgvu+HS3Ldst/df/zqOuwDqcB/7xSgG9HG5Bd8AkYHCaHu+DiQDsCCIj
         5wwg==
X-Gm-Message-State: AHQUAuYfi2B0asSGJYMiEYQclGYkWz1oY0a/rzdzCxGD5Dw9g4m8f5nF
	EfOQ0vIBEbNNTIsnNk8BTgmPOa/RzFCz8JYc3oPRitqZqB1iFQraRtbrcoEMAQB0RMncyiU4SF5
	S3fMNBGhto0x+y3f6OPyfBsTiEHQG9rkD8SfrFzNT6LfwqY4YLo3uTGvVY1Sjy60G/QyVijOC1y
	/N9DGQhR5sQ2fFdVSZZatn//VYN1Axtk5Ckd+zgF+cwtooXkd2jdQJkSqDo5SrsUb/Ybm/Iqn6e
	xDo7oIGcNTu9W+FvShmeZWR9Neb9fNPuhNZApOSLRgZSXDi6gf4zQFNa8YPk/WE56tKxEbIw+tt
	m32Ur32vLSDeJC3aiqqkubhV98DVEBf8yjw+S/EHhMZVBd9rQwqlG7Lg27oasPf9H39gKJoGToM
	0
X-Received: by 2002:a62:509b:: with SMTP id g27mr14529826pfj.48.1549517589728;
        Wed, 06 Feb 2019 21:33:09 -0800 (PST)
X-Received: by 2002:a62:509b:: with SMTP id g27mr14529773pfj.48.1549517588898;
        Wed, 06 Feb 2019 21:33:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549517588; cv=none;
        d=google.com; s=arc-20160816;
        b=cIw904TZ5LJTTLABgZJHSp2CSix8tnDl4sQfRaBizOfCnp7pVuo5u4XW/nx3yW5xSf
         LMaEGnNO3YtHnJTkJcIeGFFiqM3QESVN7oqdtIaNbv8IidrZcrvvZGdzZ3+cDHk4NOWl
         etbyCwiJ2kgzxPJDC3KORhdrlrhEBEg9eUbGfQXIRIa6rrzVCN06H+c6APX1RQVQGucA
         pMM3mcFqiTIW8m4Hru67vw7ZW/1iY9f+J9e+TPxBO2x71PjDMifrqy1wN3rS/pJJF3dU
         4jfdZtRtQ2V8ZEW2KRLzQghsw6611n6RS13Hcl7k4OAt+589/5FEKJtEF033StGeFt1j
         mzyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1dhO9WZwCYTMt9fJvM1nNU2p7dvIM4HOJh/eYKYBoFs=;
        b=TQpqI9Stk1+vySArI8uPHgbIO0bY+BxosJuW7QWmn2HJrURtx0RgkjOkqVcniG62y7
         lbr4c53bvaeLExi6E1uuUZBuZokvbh8mumCjB4VIM+zimHewcoOmCnFDM0eBUagVi6it
         wD/msI4zQQqXbMMVfY7p33/fPqTebz3bCv0RgAySvTVNCbS0oLz5ir7CLurBRh5idByh
         9JbxmfldP7KYBN3LmZuqkzug2gLcBnLxmnFiYeYr5kzhLd6idMdp+Cw4OVB/tE/icpmV
         4FVyEORKIPcf8ziuS6PyXCJyD37VXqy5o8mmG/qwIHozSyAz8+WMVbAHrlumHosy3hRP
         38JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O6JuEwwu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor11948312plo.4.2019.02.06.21.33.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 21:33:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O6JuEwwu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1dhO9WZwCYTMt9fJvM1nNU2p7dvIM4HOJh/eYKYBoFs=;
        b=O6JuEwwu6hKxxjXIys11QD16tgPe+A/2DnTr+z70AF3t0OVv1xdrIWoLuBKwz7HbIf
         iK+grMOhLiKkNbqOjg5yXtOoS4+o+jyUzZun6Nii5nU6IzXwJNZl1sWS+zC5vGNdbQ9N
         Q1jQHPwzNejWMzbh1nqmfapYsNafb5dvk/ipc36uEXNaD4va1okaOSVX+enNwIWTzdoV
         TAuJCe+EfVZna2FV4lI+R69LJDjhKWFr5CNS4i3vmw9NTidXYJviCPvM55UC+Eq4Z5Dc
         J5Mr45BsFeby+nhsnN//IzTSVyqB5FTN1uph3WPH9WKxgnp6M8RPR9qTpXPrgyb64Ivg
         vngg==
X-Google-Smtp-Source: AHgI3IbyZL2bQvLtIVzm60K+WCG18pBAkuTCrejV7d1gkE6Wvzsqz9paL7ZhpctoTkIDp+YArLkIEA==
X-Received: by 2002:a17:902:722:: with SMTP id 31mr14770884pli.271.1549517588507;
        Wed, 06 Feb 2019 21:33:08 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id 196sm22681710pfc.77.2019.02.06.21.33.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 21:33:07 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grcJ9-00067N-8V; Wed, 06 Feb 2019 22:33:07 -0700
Date: Wed, 6 Feb 2019 22:33:07 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Doug Ledford <dledford@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207053307.GB22726@ziepe.ca>
References: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <20190206232130.GK12227@ziepe.ca>
 <CAPcyv4g2r=L3jfSDoRPt4VG7D_2CxCgv3s+JLu4FQRUSRWg+4Q@mail.gmail.com>
 <20190206234132.GB15234@ziepe.ca>
 <CAPcyv4h1=GTAqHBw+Zsp9eNYR3HFbB_qjmhntwnO-jyGun4QNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4h1=GTAqHBw+Zsp9eNYR3HFbB_qjmhntwnO-jyGun4QNA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 04:22:16PM -0800, Dan Williams wrote:
> On Wed, Feb 6, 2019 at 3:41 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> [..]
> > > You're describing the current situation, i.e. Linux already implements
> > > this, it's called Device-DAX and some users of RDMA find it
> > > insufficient. The choices are to continue to tell them "no", or say
> > > "yes, but you need to submit to lease coordination".
> >
> > Device-DAX is not what I'm imagining when I say XFS--.
> >
> > I mean more like XFS with all features that require rellocation of
> > blocks disabled.
> >
> > Forbidding hold punch, reflink, cow, etc, doesn't devolve back to
> > device-dax.
> 
> True, not all the way, but the distinction loses significance as you
> lose fs features.
> 
> Filesystems mark DAX functionality experimental [1] precisely because
> it forbids otherwise typical operations that work in the nominal page
> cache case. An approach that says "lets cement the list of things a
> filesystem or a core-memory-mangement facility can't do because RDMA
> finds it awkward" is bad precedent. 

I'm not saying these rules should apply globaly.

I'm suggesting you could have a FS that supports gup_longterm by
design, and a FS that doesn't. And that is OK. They can have different
rules.

Obviously the golden case here is to use ODP (which doesn't call
gup_longterm at all) - that works for both.

Supporting non-ODP is a trade off case - users that want to run on
limited HW must accept limited functionality. Limited functionality is
better than no-funtionality.

Linux has many of these user-choose tradeoffs. This is how it supports
such a wide range of HW capabilities. Not all HW can do all
things. Some features really do need HW support. It has always been
that way.

Jason

