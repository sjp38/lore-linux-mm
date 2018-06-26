Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD7BF6B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 11:00:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l2-v6so8916154pff.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:00:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q13-v6si1879756plr.220.2018.06.26.08.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 08:00:28 -0700 (PDT)
Message-ID: <1530025017.27091.1.camel@intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 26 Jun 2018 07:56:57 -0700
In-Reply-To: <CALCETrWYx5nCtwGAqTZBWOB+aw+eEcnQhe6Sn1o+O356g7Km9A@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <CALCETrWYx5nCtwGAqTZBWOB+aw+eEcnQhe6Sn1o+O356g7Km9A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Linux API <linux-api@vger.kernel.org>, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Mon, 2018-06-25 at 22:26 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > This series introduces CET - Shadow stack
> I think you should add some mitigation against sigreturn-oriented
> programming.A A How about creating some special token on the shadow
> stack that indicates the presence of a signal frame at a particular
> address when delivering a signal and verifying and popping that token
> in sigreturn?A A The token could be literally the address of the signal
> frame, and you could make this unambiguous by failing sigreturn if
> CET
> is on and the signal frame is in executable memory.
> 
> IOW, it would be a shame if sigreturn() itself became a convenient
> CET-bypassing gadget.
> 
> --Andy

I will look into that.

Thanks,
Yu-cheng
