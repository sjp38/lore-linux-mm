Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDAF280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 18:27:49 -0400 (EDT)
Received: by qged69 with SMTP id d69so10278136qge.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:27:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m2si11369872qhb.129.2015.07.16.15.27.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 15:27:48 -0700 (PDT)
Date: Fri, 17 Jul 2015 00:26:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] mm, mpx: add "vm_flags_t vm_flags" arg to
	do_mmap_pgoff()
Message-ID: <20150716222603.GA21791@redhat.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com> <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com> <20150713165323.GA7906@redhat.com> <55A3EFE9.7080101@linux.intel.com> <20150716110503.9A4F5196@black.fi.intel.com> <55A7D38C.7070907@linux.intel.com> <20150716160927.GA27037@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716160927.GA27037@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On 07/16, Kirill A. Shutemov wrote:
>
> On Thu, Jul 16, 2015 at 08:53:48AM -0700, Dave Hansen wrote:
> > On 07/16/2015 04:05 AM, Kirill A. Shutemov wrote:
> > >> > These both look nice to me (and they both cull specialty MPX code which
> > >> > is excellent).  I'll run them through a quick test.
> > > Any update?
> >
> > Both patches look fine to me and test OK.  Feel free to add my
> > acked/tested/etc...
>
> Oleg, could you prepare a proper patch with description/signed-off-by?
>
> I'll send updated patchset with all changes to Andrew.

With pleasure, please see 1/1.

Changes:

	- s/__do_mmap_pgoff/do_mmap/

	- update mm/nommu.c too

	- make do_mmap_pgoff() inline (perhaps we should kill it),
	  this also avoids another change in nommu.c

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
