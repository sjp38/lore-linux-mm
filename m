Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 400056B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 11:50:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Sat, 3 Aug 2013 01:40:43 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 307772BB004F
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 01:50:34 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72FYk2e55574724
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 01:34:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r72FoTrW014323
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 01:50:29 +1000
Date: Fri, 2 Aug 2013 10:50:26 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH] drivers: base: new memory config sysfs driver for large
 memory systems
Message-ID: <20130802155026.GA4550@variantweb.net>
References: <1374786680-26197-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130725234007.GB18349@kroah.com>
 <20130726144251.GB4379@variantweb.net>
 <20130801205724.GA13585@kroah.com>
 <51FADD6F.3040804@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FADD6F.3040804@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Nivedita Singhvi <niv@us.ibm.com>, Michael J Wolf <mjwolf@us.ibm.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Thu, Aug 01, 2013 at 03:13:03PM -0700, Dave Hansen wrote:
> On 08/01/2013 01:57 PM, Greg Kroah-Hartman wrote:
> >> > "memory" is the name used by the current sysfs memory layout code in
> >> > drivers/base/memory.c. So it can't be the same unless we are going to
> >> > create a toggle a boot time to select between the models, which is
> >> > something I am looking to add if this code/design is acceptable to
> >> > people.
> > I know it can't be the same, but this is like "memory_v2" or something,
> > right?  I suggest you make it an either/or option, given that you feel
> > the existing layout just will not work properly for you.
> 
> If there are existing tools or applications that look for memory hotplug
> events, how does this interact with those?  I know you guys have control
> over the ppc software that actually performs the probe/online
> operations, but what about other apps?

After taking a closer look, I've decided to rework this to preserve more
of the existing layout.  Should be posting it next Monday.

> 
> I also don't seem to see the original post to LKML.  Did you send
> privately to Greg, then he cc'd LKML on his reply?

Yeah :-/  My mail relay settings were messed up and my system tried to
deliver the mail directly to recipients; some of which worked and some
failed (spam/firewall filters, etc).  Sigh...

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
