Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD4836B007E
	for <linux-mm@kvack.org>; Sat, 21 May 2016 16:27:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 81so9770743wms.3
        for <linux-mm@kvack.org>; Sat, 21 May 2016 13:27:59 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id c70si5614414wme.44.2016.05.21.13.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 May 2016 13:27:57 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n129so5172944wmn.1
        for <linux-mm@kvack.org>; Sat, 21 May 2016 13:27:57 -0700 (PDT)
Date: Sat, 21 May 2016 22:27:52 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv9 2/2] selftest/x86: add mremap vdso test
Message-ID: <20160521202752.GA31710@gmail.com>
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
 <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
 <20160520064820.GB29418@gmail.com>
 <CALCETrWznziSzwu3gG6bcFAxPvboTF519iTS6F8+WVW0B4i4UQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWznziSzwu3gG6bcFAxPvboTF519iTS6F8+WVW0B4i4UQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Thu, May 19, 2016 at 11:48 PM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> >
> >> Should print on success:
> >> [root@localhost ~]# ./test_mremap_vdso_32
> >>       AT_SYSINFO_EHDR is 0xf773f000
> >> [NOTE]        Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
> >> [OK]
> >> Or segfault if landing was bad (before patches):
> >> [root@localhost ~]# ./test_mremap_vdso_32
> >>       AT_SYSINFO_EHDR is 0xf774f000
> >> [NOTE]        Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
> >> Segmentation fault (core dumped)
> >
> > So I still think that generating potential segfaults is not a proper way to test a
> > new feature. How are we supposed to tell the feature still works? I realize that
> > glibc is a problem here - but that doesn't really change the QA equation: we are
> > adding new kernel code to help essentially a single application out of tens of
> > thousands of applications.
> >
> > At minimum we should have a robust testcase ...
> 
> I think it's robust enough.  It will print "[OK]" and exit with 0 on
> success and it will crash on failure.  The latter should cause make
> run_tests to fail reliably.

Indeed, you are right - I somehow mis-read it as potentially segfaulting on fixed 
kernels as well...

Will look at applying this after the merge window.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
