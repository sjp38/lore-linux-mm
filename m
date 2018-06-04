Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB9D06B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:22:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v12-v6so4344614wmc.1
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:22:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w11-v6si845686edf.375.2018.06.04.05.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 05:22:47 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w54CJEj2076816
	for <linux-mm@kvack.org>; Mon, 4 Jun 2018 08:22:45 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jd3shv79b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Jun 2018 08:22:44 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 4 Jun 2018 13:22:42 +0100
Date: Mon, 4 Jun 2018 15:22:35 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] docs/admin-guide/mm: add high level concepts overview
References: <20180529113725.GB13092@rapoport-lnx>
 <285dd950-0b25-dba3-60b6-ceac6075fb48@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <285dd950-0b25-dba3-60b6-ceac6075fb48@infradead.org>
Message-Id: <20180604122235.GB15196@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Randy,

Thanks for the review! I always have trouble with articles :)
The patch below addresses most of your comments.

On Fri, Jun 01, 2018 at 05:09:38PM -0700, Randy Dunlap wrote:
> On 05/29/2018 04:37 AM, Mike Rapoport wrote:
> > Hi,
> > 
> > From 2d3ec7ea101a66b1535d5bec4acfc1e0f737fd53 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Date: Tue, 29 May 2018 14:12:39 +0300
> > Subject: [PATCH] docs/admin-guide/mm: add high level concepts overview
> > 
> > The are terms that seem obvious to the mm developers, but may be somewhat

Huh, I afraid it's to late to change the commit message :(
 
>   There are [or: These are]
> 
> > obscure for, say, less involved readers.
> > 
> > The concepts overview can be seen as an "extended glossary" that introduces
> > such terms to the readers of the kernel documentation.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  Documentation/admin-guide/mm/concepts.rst | 222 ++++++++++++++++++++++++++++++
> >  Documentation/admin-guide/mm/index.rst    |   5 +
> >  2 files changed, 227 insertions(+)
> >  create mode 100644 Documentation/admin-guide/mm/concepts.rst
> > 
> > diff --git a/Documentation/admin-guide/mm/concepts.rst b/Documentation/admin-guide/mm/concepts.rst
> > new file mode 100644
> > index 0000000..291699c
> > --- /dev/null
> > +++ b/Documentation/admin-guide/mm/concepts.rst

[...]

> > +All this makes dealing directly with physical memory quite complex and
> > +to avoid this complexity a concept of virtual memory was developed.
> > +
> > +The virtual memory abstracts the details of physical memory from the
> 
>        virtual memory {system, implementation} abstracts
> 
> > +application software, allows to keep only needed information in the
> 
>                software, allowing the VM to keep only needed information in the
> 
> > +physical memory (demand paging) and provides a mechanism for the
> > +protection and controlled sharing of data between processes.
> > +

My intention was "virtual memory concept allows ... and provides ..."
I didn't want to repeat "concept", to I've just omitted it.

Somehow, I don't feel that "system" or "implementation" fit here...

> 
> -- 
> ~Randy
> 

-- 
Sincerely yours,
Mike.
