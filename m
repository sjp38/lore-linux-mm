Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE846B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:16:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so5823632pgv.12
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:16:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y18-v6sor535752pfj.53.2018.07.20.05.16.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:16:21 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:16:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 02/19] mm: Do not use zero page in encrypted pages
Message-ID: <20180720121616.oqzoj6dgm6iws5xz@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
 <e09c67ab-38a7-5b76-29e6-a45627eec1e5@intel.com>
 <20180719071606.dkeq5btz5wlzk4oq@kshutemo-mobl1>
 <d50d89d2-f93b-4b4b-bf8d-2f53cedebcd1@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d50d89d2-f93b-4b4b-bf8d-2f53cedebcd1@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 06:58:14AM -0700, Dave Hansen wrote:
> On 07/19/2018 12:16 AM, Kirill A. Shutemov wrote:
> > On Wed, Jul 18, 2018 at 10:36:24AM -0700, Dave Hansen wrote:
> >> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> >>> Zero page is not encrypted and putting it into encrypted VMA produces
> >>> garbage.
> >>>
> >>> We can map zero page with KeyID-0 into an encrypted VMA, but this would
> >>> be violation security boundary between encryption domains.
> >> Why?  How is it a violation?
> >>
> >> It only matters if they write secrets.  They can't write secrets to the
> >> zero page.
> > I believe usage of zero page is wrong here. It would indirectly reveal
> > content of supposedly encrypted memory region.
> > 
> > I can see argument why it should be okay and I don't have very strong
> > opinion on this.
> 
> I think we should make the zero page work.  If folks are
> security-sensitive, they need to write to guarantee it isn't being
> shared.  That's a pretty low bar.
> 
> I'm struggling to think of a case where an attacker has access to the
> encrypted data, the virt->phys mapping, *and* can glean something
> valuable from the presence of the zero page.

Okay.

> Please spend some time and focus on your patch descriptions.  Use facts
> that are backed up and are *precise* or tell the story of how your patch
> was developed.  In this case, citing the "security boundary" is not
> precise enough without explaining what the boundary is and how it is
> violated.

Fair enough. I'll go though all commit messages once again. Sorry.

-- 
 Kirill A. Shutemov
