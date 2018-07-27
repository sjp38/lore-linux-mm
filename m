Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 918596B000D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:27:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l26-v6so5175850oii.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:27:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h77-v6si3479760oig.370.2018.07.27.14.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:27:29 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6RLIVNs090044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:27:28 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kg6d0kn1w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:27:28 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jul 2018 22:27:26 +0100
Date: Sat, 28 Jul 2018 00:27:21 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 6/7] docs/mm: make GFP flags descriptions usable as
 kernel-doc
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532626360-16650-7-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726160825.0667af9f@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726160825.0667af9f@lwn.net>
Message-Id: <20180727212720.GD17745@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 04:08:25PM -0600, Jonathan Corbet wrote:
> On Thu, 26 Jul 2018 20:32:39 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > This patch adds DOC: headings for GFP flag descriptions and adjusts the
> > formatting to fit sphinx expectations of paragraphs.
> 
> So I think this is a great thing to do.  Adding cross references from
> places where GFP flags are expected would be even better.  I do have one
> little concern, though...
> 
> > - * __GFP_MOVABLE (also a zone modifier) indicates that the page can be
> > - *   moved by page migration during memory compaction or can be reclaimed.
> > + * %__GFP_MOVABLE (also a zone modifier) indicates that the page can be
> > + * moved by page migration during memory compaction or can be reclaimed.
> 
> There are Certain Developers who get rather bent out of shape when they
> feel that excessive markup is degrading the readability of the plain-text
> documentation.  I have a suspicion that all of these % signs might turn
> out to be one of those places.  People have been trained to expect them in
> function documentation, but that's not quite what we have here.
> 
> I won't insist on this, but I would suggest that, in this particular case,
> it might be better for that markup to come out.

No problem with removing % signs, but the whitespace changes are necessary,
otherwise the generated html gets weird.
 
> Then we have the same old question of who applies these.  I'd love to have
> an ack from somebody who can speak for mm - or a statement that these will
> go through another tree.  Preferably quickly so that this stuff can get
> in through the upcoming merge window.

> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.
