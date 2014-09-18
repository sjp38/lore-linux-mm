Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id EF0506B0072
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 02:17:53 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id rl12so541234iec.16
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 23:17:53 -0700 (PDT)
Received: from chicago.guarana.org (chicago.guarana.org. [198.144.183.183])
        by mx.google.com with ESMTP id jd9si1439236igb.35.2014.09.17.23.17.52
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 23:17:53 -0700 (PDT)
Date: Thu, 18 Sep 2014 17:17:41 +1000
From: Kevin Easton <kevin@guarana.org>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Message-ID: <20140918071741.GA29963@chicago.guarana.org>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
 <20140916075007.GA22076@chicago.guarana.org>
 <9E0BE1322F2F2246BD820DA9FC397ADE017B32C6@shsmsx102.ccr.corp.intel.com>
 <20140918032334.GA26560@chicago.guarana.org>
 <541A62DD.7080502@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <541A62DD.7080502@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 17, 2014 at 09:43:09PM -0700, Dave Hansen wrote:
> On 09/17/2014 08:23 PM, Kevin Easton wrote:
> > I was actually thinking that the kernel would take care of the xsave / 
> > xrstor (for current), updating tsk->thread.fpu.state (for non-running
> > threads) and sending an IPI for threads running on other CPUs.
> > 
> > Of course userspace can always then manually change the bounds directory
> > address itself, but then it's quite clear that they're doing something
> > unsupported.  Just an idea, anyway.
> 
> What's the benefit of that?
> 
> As it stands now, MPX is likely to be enabled well before any threads
> are created, and the MPX enabling state will be inherited by the new
> thread at clone() time.  The current mechanism allows a thread to
> individually enable or disable MPX independently of the other threads.
> 
> I think it makes it both more complicated and less flexible.

I was assuming that if an application did want to enable MPX after threads
had already been created, it would generally want to enable it
simultaneously across all threads.  This would be a lot easier for the
kernel than for the application.

    - Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
