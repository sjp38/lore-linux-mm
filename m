Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C18AC4360F
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 22:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0808720657
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 22:48:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0808720657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E1698E0007; Sun, 10 Mar 2019 18:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51B2F8E0002; Sun, 10 Mar 2019 18:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 431298E0007; Sun, 10 Mar 2019 18:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01EB48E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:48:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q21so3992421pfi.17
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 15:48:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UCUFSIa7ypNQ0JhntzOmZLHEn/A4vAEyAt7CKsL2rxw=;
        b=kwipXKM7VQ3Hlhb8XR0deQ9r23BYFgagN9d8eDWc5ng7oLpEEq9XDKwNfrSNtiFOz5
         4jVo9CkCfrBGTRSManRTebat67qOXyCTSQQS5L+uCGLc3df1P6Zw8zMdAOUTtpf3SEi7
         d7//gAmAjNMKc3uPo2Cxvn/rU3mRAJnkTedBqFTsnoI96CwC0Y67/jip6jeCiZSKWM8n
         IHClwMOk8zO0O/4aeIi/T6iVC9NDDfyZnmgMc4CBWQLtu1rYnhRQQMJSPDV0xkwzYGiM
         267mWBPVOYwRXbiCUOcxTih/Tn1iLDDdN1PE2SrjLj8MpKOH9Ex1dTx35tNzOrSiZyOD
         oycg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUs9MYTQaEobXFJkNxcAHDoubYZOyOBh67Wa8Qz3r6mMJeASqFl
	5AQLWAFKAODj5XUIQQ5N8/NBg7LEQNLzonAMXehBjTFhxNGMBSZsCzSIsLSL0rTh6+cPtx5e1nx
	PrHSxYVYmS4soYvH66jXw0Q5Mof0Ucv1RstPPxMzDEJ092D0gkuh0XAbn/IUtBek=
X-Received: by 2002:a62:8384:: with SMTP id h126mr29864716pfe.243.1552258080543;
        Sun, 10 Mar 2019 15:48:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzng6iXcIvVdcLw5eNgaWkmoxg8uDc4/m/pEL5O6Z5LyccSfBhXMvaoVxFRpjnEqgdxMEJU
X-Received: by 2002:a62:8384:: with SMTP id h126mr29864661pfe.243.1552258079581;
        Sun, 10 Mar 2019 15:47:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552258079; cv=none;
        d=google.com; s=arc-20160816;
        b=j3ryqD7P8dxJlImngn7uwMYjrtnPOHTEr5E+4zE7zxjj5l4tPpBs6A/gnAGu2yUU3M
         aWLrNpwFqzwLgBdoaWsP7mp0CvAZVHy+/v1r0dyFWbxhKic6a4hUJMt723Jw85hWwPm5
         BZUezTgatn1EQiNSHax1ybTXHcRv8bEsSfEz2Yrsn856BZiJnGgRufzQgGQUKrFzImZL
         5g3MTdh3wzVLYNWH5VJFvgCL8NbQcwtXfvYW18/w6VWOaCaOt2QWfFwdsi3QSk/HdjdH
         9MdNSYxWyg38BpJgyr22uTyAjA1lXdthKApf6eRfi0t0sVDZoF3ttuNrfdZx5xWyPlgw
         +rEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UCUFSIa7ypNQ0JhntzOmZLHEn/A4vAEyAt7CKsL2rxw=;
        b=k2U7nvfjrZvSV6QWFxJfV0pV6E1TO8A0Nu9U/qkNNc598rVRs07nOTmDxtxQ5LlH+O
         u4yj8tm7ZEXSmhDwbQGHLbSVDFyxIg1okPxJ04gG8soQPz1ROgUMtyKzCMvdCCbxhT0H
         JfZCKOBASIAHz8fst3kCC6G5TWhj0XMH0/QuO6ml0/frd55GuDbrDhtX+efCz2wG15d5
         +h1lkI8vIlcvP9glbvmXN5gibds989FS3xB5FgdnQdR+cjqu8kgVjMPL/LgFiI1/HXfD
         1QEFOptjGZoic917vdja2+EdNdtCbQV8uIDf2Ds3p86u/NL6h82ugE/c+uutx6E4izl/
         30Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id n15si2739079pgv.398.2019.03.10.15.47.58
        for <linux-mm@kvack.org>;
        Sun, 10 Mar 2019 15:47:59 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 11 Mar 2019 09:17:43 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h37EM-000788-Dm; Mon, 11 Mar 2019 09:47:42 +1100
Date: Mon, 11 Mar 2019 09:47:42 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christopher Lameter <cl@linux.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190310224742.GK26298@dastard>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:08:40AM +0000, Christopher Lameter wrote:
> On Wed, 6 Mar 2019, john.hubbard@gmail.com wrote:
> > Direct IO
> > =========
> >
> > Direct IO can cause corruption, if userspace does Direct-IO that writes to
> > a range of virtual addresses that are mmap'd to a file.  The pages written
> > to are file-backed pages that can be under write back, while the Direct IO
> > is taking place.  Here, Direct IO races with a write back: it calls
> > GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
> > The race window is pretty small, which is probably why years have gone by
> > before we noticed this problem: Direct IO is generally very quick, and
> > tends to finish up before the filesystem gets around to do anything with
> > the page contents.  However, it's still a real problem.  The solution is
> > to never let GUP return pages that are under write back, but instead,
> > force GUP to take a write fault on those pages.  That way, GUP will
> > properly synchronize with the active write back.  This does not change the
> > required GUP behavior, it just avoids that race.
> 
> Direct IO on a mmapped file backed page doesnt make any sense.

People have used it for many, many years as zero-copy data movement
pattern. i.e. mmap the destination file, use direct IO to DMA direct
into the destination file page cache pages, fdatasync() to force
writeback of the destination file.

Now we have copy_file_range() to optimise this sort of data
movement, the need for games with mmap+direct IO largely goes away.
However, we still can't just remove that functionality as it will
break lots of random userspace stuff...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

