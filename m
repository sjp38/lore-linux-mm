Subject: Re: 2.5.44-mm2 CONFIG_SHAREPTE necessary for starting KDE 3.0.3
From: Steven Cole <scole@lanl.gov>
In-Reply-To: <1035306108.13078.178.camel@spc9.esa.lanl.gov>
References: <1035306108.13078.178.camel@spc9.esa.lanl.gov>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 11:20:36 -0600
Message-Id: <1035307236.13083.183.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 11:01, Steven Cole wrote:
> Greetings all,
> 
> My experience with 2.5.44-mm2 and KDE 3 runs counter to the experience
> of some others.  I've booted several kernels this morning on my UP test
> box and found that starting KDE 3.0.3 using XFree86 4.2.1 _requires_
> that CONFIG_SHAREPTE=y for my system.  All kernels were UP and PREEMPT.
> With CONFIG_X86_UP_IOAPIC=y and nmi_watchdog=1, the results were the
> same.
> 
> If SHAREPTE is not set, then the KDE startup fails with a frozen pointer
> after the initial dark blue screen changes to black.  This does appear
> to be KDE-related.  When Gnome is my default desktop, that works just
> fine with 2.5.44-mm2 and CONFIG_SHAREPTE not set.
> 

After reading my own mail, I realized that I should have checked to see
if disabling PREEMPT did any good in this case. 

I just booted 2.5.44-mm2 without PREEMPT and without SHAREPTE, and KDE
3.0.3 was able to start up OK.

Steven  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
