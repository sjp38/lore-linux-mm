Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BC7902802F9
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 11:53:50 -0400 (EDT)
Received: by padck2 with SMTP id ck2so44679806pad.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 08:53:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id rq3si13721122pbc.28.2015.07.16.08.53.49
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 08:53:49 -0700 (PDT)
Message-ID: <55A7D38C.7070907@linux.intel.com>
Date: Thu, 16 Jul 2015 08:53:48 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com> <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com> <20150713165323.GA7906@redhat.com> <55A3EFE9.7080101@linux.intel.com> <20150716110503.9A4F5196@black.fi.intel.com>
In-Reply-To: <20150716110503.9A4F5196@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On 07/16/2015 04:05 AM, Kirill A. Shutemov wrote:
>> > These both look nice to me (and they both cull specialty MPX code which
>> > is excellent).  I'll run them through a quick test.
> Any update?

Both patches look fine to me and test OK.  Feel free to add my
acked/tested/etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
