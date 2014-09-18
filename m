Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 761846B005C
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 00:43:25 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so588839pde.3
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 21:43:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id di2si37627527pbc.134.2014.09.17.21.43.23
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 21:43:24 -0700 (PDT)
Message-ID: <541A62DD.7080502@intel.com>
Date: Wed, 17 Sep 2014 21:43:09 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <20140916075007.GA22076@chicago.guarana.org> <9E0BE1322F2F2246BD820DA9FC397ADE017B32C6@shsmsx102.ccr.corp.intel.com> <20140918032334.GA26560@chicago.guarana.org>
In-Reply-To: <20140918032334.GA26560@chicago.guarana.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>, "Ren, Qiaowei" <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 09/17/2014 08:23 PM, Kevin Easton wrote:
> I was actually thinking that the kernel would take care of the xsave / 
> xrstor (for current), updating tsk->thread.fpu.state (for non-running
> threads) and sending an IPI for threads running on other CPUs.
> 
> Of course userspace can always then manually change the bounds directory
> address itself, but then it's quite clear that they're doing something
> unsupported.  Just an idea, anyway.

What's the benefit of that?

As it stands now, MPX is likely to be enabled well before any threads
are created, and the MPX enabling state will be inherited by the new
thread at clone() time.  The current mechanism allows a thread to
individually enable or disable MPX independently of the other threads.

I think it makes it both more complicated and less flexible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
