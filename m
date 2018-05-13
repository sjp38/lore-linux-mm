Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96B396B0704
	for <linux-mm@kvack.org>; Sun, 13 May 2018 04:56:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t2-v6so13229097iob.23
        for <linux-mm@kvack.org>; Sun, 13 May 2018 01:56:35 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0070.hostedemail.com. [216.40.44.70])
        by mx.google.com with ESMTPS id v194-v6si4523448itb.29.2018.05.13.01.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 May 2018 01:56:34 -0700 (PDT)
Message-ID: <c681ac6df41e37c51fd87ad2b0f7e2f08f6a8f3e.camel@perches.com>
Subject: Re: [PATCH v3] mm: Change return type to vm_fault_t
From: Joe Perches <joe@perches.com>
Date: Sun, 13 May 2018 01:56:30 -0700
In-Reply-To: <CAPcyv4gYp4_9h1hsQOiHeEUX3TBZCsFWZkzrdcCi+YZ2QOKhxw@mail.gmail.com>
References: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
	 <e194731158f7f89145ed0ae28f46aac5726fc32d.camel@perches.com>
	 <20180512142451.GB24215@bombadil.infradead.org>
	 <CAFqt6zb9KzPw0ih3fOs6DNd3RCcy9GYmxZ607_w7obn0Kym7Kw@mail.gmail.com>
	 <CAPcyv4gYp4_9h1hsQOiHeEUX3TBZCsFWZkzrdcCi+YZ2QOKhxw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, 2018-05-12 at 19:51 -0700, Dan Williams wrote:
> On Sat, May 12, 2018 at 12:14 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > > > It'd be nicer to realign the 2nd and 3rd arguments
> > > > on the subsequent lines.
> > > > 
> > > >       vm_fault_t (*fault)(const struct vm_special_mapping *sm,
> > > >                           struct vm_area_struct *vma,
> > > >                           struct vm_fault *vmf);
> > > > 
> > > It'd be nicer if people didn't try to line up arguments at all and
> > > just indented by an extra two tabs when they had to break a logical
> > > line due to the 80-column limit.
> > 
> > Matthew, there are two different opinions. Which one to take ?
> 
> Unfortunately this is one of those "maintainer's choice" preferences
> that drives new contributors crazy. Just go with the two tabs like
> Matthew said and be done.

The only reason I mentioned it was the old function name
was aligned that way with arguments aligned to the open
parenthesis.

Renaming the function should keep the same alignment style
and not just rename the function.

-	int (*fault)(const struct vm_special_mapping *sm,
+	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *vma,
 		     struct vm_fault *vmf);

Here the previous indent was 2 tabs, 5 spaces
