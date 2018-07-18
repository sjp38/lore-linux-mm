Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72B8C6B026A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:00:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p7-v6so2179507eds.19
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:00:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f12-v6si3147564eds.462.2018.07.18.10.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 10:00:54 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6IGsUtR068181
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:00:53 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ka95m9249-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:00:52 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Jul 2018 18:00:50 +0100
Date: Wed, 18 Jul 2018 20:00:43 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180702113255.1f7504e2@lwn.net>
 <20180718114730.GD4302@rapoport-lnx>
 <20180718060249.6b45605d@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718060249.6b45605d@lwn.net>
Message-Id: <20180718170043.GA23770@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

(added Andrew)

On Wed, Jul 18, 2018 at 06:02:49AM -0600, Jonathan Corbet wrote:
> On Wed, 18 Jul 2018 14:47:30 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > > So this seems like good stuff overall.  It digs pretty deeply into the mm
> > > code, though, so I'm a little reluctant to apply it without an ack from an
> > > mm developer.  Alternatively, I'm happy to step back if Andrew wants to
> > > pick the set up.  
> > 
> > Jon, does Michal's reply [1] address your concerns?
> > Or should I respin and ask Andrew to pick it up? 
> > 
> > [1] https://lore.kernel.org/lkml/20180712080006.GA328@dhcp22.suse.cz/
> 
> Michal acked #11 (the docs patch) in particular but not the series as a
> whole.  But it's the rest of the series that I was most worried about :)
> I'm happy for the patches to take either path, but I'd really like an
> explicit ack before I apply that many changes directly to the MM code...

Andrew,

Can you please take a look at this series? The thread starts at [1] and if
it'd be more convenient to you I can respin the whole set.
 
[1] https://lore.kernel.org/lkml/1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com/

> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.
