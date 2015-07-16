Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 18A7D2802F9
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:09:38 -0400 (EDT)
Received: by widic2 with SMTP id ic2so19338576wid.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 09:09:37 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id ep10si14585086wjd.3.2015.07.16.09.09.36
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 09:09:37 -0700 (PDT)
Date: Thu, 16 Jul 2015 19:09:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Message-ID: <20150716160927.GA27037@node.dhcp.inet.fi>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150713165323.GA7906@redhat.com>
 <55A3EFE9.7080101@linux.intel.com>
 <20150716110503.9A4F5196@black.fi.intel.com>
 <55A7D38C.7070907@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55A7D38C.7070907@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jul 16, 2015 at 08:53:48AM -0700, Dave Hansen wrote:
> On 07/16/2015 04:05 AM, Kirill A. Shutemov wrote:
> >> > These both look nice to me (and they both cull specialty MPX code which
> >> > is excellent).  I'll run them through a quick test.
> > Any update?
> 
> Both patches look fine to me and test OK.  Feel free to add my
> acked/tested/etc...

Oleg, could you prepare a proper patch with description/signed-off-by?

I'll send updated patchset with all changes to Andrew.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
