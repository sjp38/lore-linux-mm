Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5545E6B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:06:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w15-v6so2272480pge.2
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:06:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e21-v6si1570405pgk.311.2018.10.03.09.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:06:49 -0700 (PDT)
Message-ID: <5ddb0ad33298d1858e530fce9c9ea2788b2fac81.camel@intel.com>
Subject: Re: [RFC PATCH v4 24/27] mm/mmap: Create a guard area between VMAs
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 03 Oct 2018 09:00:04 -0700
In-Reply-To: <CALCETrU-Ny-uC1NqRedQwNKe2MMhsFEqZ08TtHJwbLfCACMmLw@mail.gmail.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-25-yu-cheng.yu@intel.com>
	 <20181003045611.GB22724@asgard.redhat.com>
	 <CALCETrU-Ny-uC1NqRedQwNKe2MMhsFEqZ08TtHJwbLfCACMmLw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Eugene Syromiatnikov <esyr@redhat.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Tue, 2018-10-02 at 22:36 -0700, Andy Lutomirski wrote:
> On Tue, Oct 2, 2018 at 9:55 PM Eugene Syromiatnikov <esyr@redhat.com> wrote:
> > 
> > On Fri, Sep 21, 2018 at 08:03:48AM -0700, Yu-cheng Yu wrote:
> > > Create a guard area between VMAs, to detect memory corruption.
> > 
> > Do I understand correctly that with this patch a user space program
> > no longer be able to place two mappings back to back? If it is so,
> > it will likely break a lot of things; for example, it's a common ring
> > buffer implementations technique, to map buffer memory twice back
> > to back in order to avoid special handling of items wrapping its end.
> 
> I haven't checked what the patch actually does, but it shouldn't have
> any affect on MAP_FIXED or the new no-replace MAP_FIXED variant.
> 
> --Andy

I did some mmap tests with/without MAP_FIXED, and it works as intended.
In addition to the ring buffer, are there other test cases?

Yu-cheng
