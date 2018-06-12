Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12BF06B0277
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:06:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so4710514plo.9
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:06:51 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id k17-v6si321071pfe.205.2018.06.12.08.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 08:06:50 -0700 (PDT)
Message-ID: <1528815820.8271.16.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 12 Jun 2018 08:03:40 -0700
In-Reply-To: <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> 
> On 08/06/18 00:37, Yu-cheng Yu wrote:
> > This series introduces CET - Shadow stack
> > 
> > At the high level, shadow stack is:
> > 
> > 	Allocated from a task's address space with vm_flags VM_SHSTK;
> > 	Its PTEs must be read-only and dirty;
> > 	Fixed sized, but the default size can be changed by sys admin.
> > 
> > For a forked child, the shadow stack is duplicated when the next
> > shadow stack access takes place.
> > 
> > For a pthread child, a new shadow stack is allocated.
> > 
> > The signal handler uses the same shadow stack as the main program.
> > 
> 
> Even with sigaltstack()?
> 
> 
> Balbir Singh.

Yes.
