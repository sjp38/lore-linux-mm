Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46CD36B026F
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:52:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so5597937plt.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:52:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a80-v6si18999175pfg.200.2018.06.07.08.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 08:52:32 -0700 (PDT)
Message-ID: <1528386560.4636.2.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 5/5] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 08:49:20 -0700
In-Reply-To: <CALCETrWVZfWUSOy6wRyVBfP2b2TzZuPt8bCe6q0Pa5r7onO+VA@mail.gmail.com>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
	 <20180607143544.3477-6-yu-cheng.yu@intel.com>
	 <CALCETrWVZfWUSOy6wRyVBfP2b2TzZuPt8bCe6q0Pa5r7onO+VA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 08:39 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> 
> Fix the subject line, please.  This is more than just docs.
> 
> >
> > Explain how CET works and the noshstk/noibt kernel parameters.
> 
> Maybe no_cet_shstk and no_cet_ibt?  noshstk sounds like gibberish and
> people might need a reminder.

I will change that.

Yu-cheng
