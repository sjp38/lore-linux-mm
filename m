Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 135136B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 00:02:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r70so40404643pfb.7
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 21:02:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q77si6145156pfj.53.2017.06.11.21.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Jun 2017 21:02:38 -0700 (PDT)
Date: Sun, 11 Jun 2017 22:02:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/3] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170612040236.GA7352@linux.intel.com>
References: <20170607204859.13104-1-ross.zwisler@linux.intel.com>
 <CAA9_cmcPsyZCB7-pd9djL0+bLamfL49SJVgkyoJ22G6tgOxyww@mail.gmail.com>
 <20170610030346.GA3575@linux.intel.com>
 <CAPcyv4jsgUfL5Cr5a342aVNKXBrtXzpuar_1U3w3auHoT2E08A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jsgUfL5Cr5a342aVNKXBrtXzpuar_1U3w3auHoT2E08A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, ext4 hackers <linux-ext4@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Jun 09, 2017 at 08:35:08PM -0700, Dan Williams wrote:
> On Fri, Jun 9, 2017 at 8:03 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > And vm_insert_mixed_mkwrite() and vm_insert_mixed() are redundant with only
> > the insert_pfn() line differing?  This doesn't seem better...unless I'm
> > missing something?
> >
> > The way it is, vm_insert_mixed_mkwrite() also closely matches
> > insert_pfn_pmd(), which we use in the PMD case and which also takes a 'write'
> > boolean which works the same as our newly added 'mkwrite'.
> 
> Hmm, but now the pfn and pmd cases are inconsistent, if you put the
> flag name in the function then don't add an argument, or make it like
> the pmd case and add an argument to vm_insert_mixed(). I prefer the
> former.

Okay, I'll fix this for v2.  Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
