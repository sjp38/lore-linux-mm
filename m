Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 244EEC43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 22:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA6B021A4A
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 22:42:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA6B021A4A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E6478E0002; Sat, 16 Feb 2019 17:42:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0988C8E0001; Sat, 16 Feb 2019 17:42:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF0CC8E0002; Sat, 16 Feb 2019 17:42:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF9E38E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 17:42:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 2so9417284pgg.21
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 14:42:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X3ip6CkqDDWn1gLVD0Z2SslNhPWtMl54rEztwbBR7aw=;
        b=WMLfvpBfhE0NM3uWqDW6bTciP0LHKYUsZ9xshOiQJAqH8RICN50bslaUZtLF7shQSH
         vV7oIZJ7T3+Dxuw5PVeiOBxzcPvpw86vz8AZdY/mrXEiwchHsGtvWQWJEFYAWdCFUC3E
         XeLNZ3iaVBby0tk++x4OrKy2FzbxEASVAYZuusxKhVbtU+0eVf88Maz6RhMzbdGBk8o2
         FquhCuru2RTv5xixfZEoW4ZpK99wiD3/EXchf3OZt3hROCguEshGEsRbxdpYGHSXDI+/
         8bN6oSaenxUFJjIlmFMrotuaXvgmiJR7yNJJjuy26WsdIyWLQ6LcGMs+SqEUaRznunnN
         rzfw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAubwZ5bvBmCHP/Eifak23Z/ApBsZqD2u1ydfoUKb/IFzxxpJf8GR
	kxznrlEfy5ufRZ5+onx+SbNXBdTirE/ZJjzVg9CoBevtUdOoWcBON7/StC3eqJavht8AKSXSXmm
	7WweJXJLudis8XeWV6I1Zexz1uf2xEFnmL8W6JhfNnNAFMNvF6PClbQxszZ4LLOc=
X-Received: by 2002:a17:902:8d8d:: with SMTP id v13mr17114232plo.121.1550356975308;
        Sat, 16 Feb 2019 14:42:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFX+roDwyAcfyNMIpcscCfNuc3ukqRGQjWSEEiuup+prz7HU9sO7NMmgsUohvR3OXfxQaw
X-Received: by 2002:a17:902:8d8d:: with SMTP id v13mr17114201plo.121.1550356974505;
        Sat, 16 Feb 2019 14:42:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550356974; cv=none;
        d=google.com; s=arc-20160816;
        b=FtiUfEP3MSoc3890fbNWrFGvl/t5eww0zXf7AXiXmQxhFsPDilPGA38DE+ea7FUOFo
         TEG5PXiEmhsRw2AYBRGnTAP1sdgVXjpQxKeT3J6bcK5NC0sb0kD0Xs6yYAgmnEvsaopR
         YunDoJHhhNebNMhzfTHZns4B+QywGbb7KfOxivj+oxJwSE9G6UInADz2i0yeEl9hvtMI
         rJ92VcVEYvwd+WPdjmE1j4J/04gcCxq70GngksNLvTlGnMg2YFr9QwPfItnqL1wU06fu
         OVRrZ1C6LMTiyS1gTkxhLdE0mgK7vzgFJTwSw6o4DNhJS//0Kt0RiFtgaYJqNF3PELJe
         KqBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X3ip6CkqDDWn1gLVD0Z2SslNhPWtMl54rEztwbBR7aw=;
        b=qryV4fq0RLHcDAdvjAIbaolq0oqU6Ki7wBmCUoGo7If1qFHLWRLpnAeK+VQF/rgQf/
         8LMUi+L/Bl6C30/l6K1qSuI4rExFMiDFYHzCyklugfePZenrnWBR57Jp4LZlkJnJIZwB
         fol/+S/9szPQgi5VbtrodeW2pyt/R+v9CdXukx4qGfAuNxoHkkhKzlyRy2DPewJwH7y2
         XA5WLOa5hA94T8Oq0bFp0FqRvlTJ/DpQEERSPiS+6uhFIMcFnQ5PIiC99iF3FprY9PHL
         w2+3MWC7c3N3cPaSF5DRPODjuPIiRXB4oo4Q4O2F4ypDIWIoqaszrALTVkRnM7Qtbho5
         qwnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id j5si9541968plk.225.2019.02.16.14.42.53
        for <linux-mm@kvack.org>;
        Sat, 16 Feb 2019 14:42:54 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 17 Feb 2019 09:12:52 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gv8fa-0001EO-S9; Sun, 17 Feb 2019 09:42:50 +1100
Date: Sun, 17 Feb 2019 09:42:50 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190216224250.GV20493@dastard>
References: <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
 <20190214213922.GD3420@redhat.com>
 <20190215011921.GS20493@dastard>
 <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
 <20190215180852.GJ12668@bombadil.infradead.org>
 <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com>
 <20190215220031.GB8001@ziepe.ca>
 <20190215233828.GB30818@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215233828.GB30818@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 03:38:29PM -0800, Ira Weiny wrote:
> On Fri, Feb 15, 2019 at 03:00:31PM -0700, Jason Gunthorpe wrote:
> > On Fri, Feb 15, 2019 at 06:31:36PM +0000, Christopher Lameter wrote:
> > > On Fri, 15 Feb 2019, Matthew Wilcox wrote:
> > > 
> > > > > Since RDMA is something similar: Can we say that a file that is used for
> > > > > RDMA should not use the page cache?
> > > >
> > > > That makes no sense.  The page cache is the standard synchronisation point
> > > > for filesystems and processes.  The only problems come in for the things
> > > > which bypass the page cache like O_DIRECT and DAX.
> > > 
> > > It makes a lot of sense since the filesystems play COW etc games with the
> > > pages and RDMA is very much like O_DIRECT in that the pages are modified
> > > directly under I/O. It also bypasses the page cache in case you have
> > > not noticed yet.
> > 
> > It is quite different, O_DIRECT modifies the physical blocks on the
> > storage, bypassing the memory copy.
> >
> 
> Really?  I thought O_DIRECT allowed the block drivers to write to/from user
> space buffers.  But the _storage_ was still under the control of the block
> drivers?

Yup, in a nutshell. Even O_DIRECT on DAX doesn't modify the physical
storage directly - it ends up in the pmem driver and it does a
memcpy() to move the data to/from the physical storage and the user
space buffer. It's exactly the same IO path as moving data to/from
the physical storage into the page cache pages....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

