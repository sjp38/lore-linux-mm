Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFD286B026E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:51:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e2-v6so3665934pgq.4
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:51:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t9-v6si16375490pgc.511.2018.06.07.08.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 08:51:03 -0700 (PDT)
Message-ID: <1528386472.4636.1.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 2/5] x86/fpu/xstate: Change some names to separate
 XSAVES system and user states
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 08:47:52 -0700
In-Reply-To: <CALCETrXAx4vBUxf3VaePNm3HHLZkdTFAR9TV0T+A-jb2QL7Uag@mail.gmail.com>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
	 <20180607143544.3477-3-yu-cheng.yu@intel.com>
	 <CALCETrXAx4vBUxf3VaePNm3HHLZkdTFAR9TV0T+A-jb2QL7Uag@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 08:38 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > To support XSAVES system states, change some names to distinguish
> > user and system states.
> >
> > Change:
> >   supervisor to system
> >   copy_init_fpstate_to_fpregs() to copy_init_fpstate_user_settings_to_fpregs()
> >   xfeatures_mask to xfeatures_mask_user
> >   XCNTXT_MASK to SUPPORTED_XFEATURES_MASK (states supported)
> 
> How about copy_init_user_fpstate_to_fpregs()?  It's shorter and more
> to the point.
> 
> --Andy

I will change that.

Yu-cheng
