Date: Tue, 26 Sep 2000 09:17:44 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000926091744.A25214@hq.fsmlabs.com>
References: <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com> <20000925171411.A2397@codepoet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000925171411.A2397@codepoet.org>; from Erik Andersen on Mon, Sep 25, 2000 at 05:14:11PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 05:14:11PM -0600, Erik Andersen wrote:
> On Mon Sep 25, 2000 at 02:04:19PM -0600, yodaiken@fsmlabs.com wrote:
> > 
> > > all of the pending requests just as long as they are serialised, is
> > > this a problem?
> > 
> > I think you are solving the wrong problem. On a small memory machine, the kernel,
> > utilities, and applications should be configured to use little memory.  
> > BusyBox is better than BeanCount. 
> > 
> 
> Granted that smaller apps can help -- for a particular workload.  But while I
> am very partial to BusyBox (in fact I am about to cut a new release) I can
> assure you that OOM is easily possible even when your user space is tiny.  I do
> it all the time.  There are mallocs in busybox and when under memory pressure,
> the kernel still tends to fall over...

Operating systems cannot make more memory appear by magic.
The question is really about the best strategy for dealing with low memory. In my
opinion, the OS should not try to out-think physical limitations. Instead, the OS 
should take as little space as possible and provide the ability for user level 
clever management of space. In a truly embedded system, there can easily be a user level
root process that watches memory usage and prevents DOS attacks -- if the OS provides
settable enforced quotas etc. 


-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
