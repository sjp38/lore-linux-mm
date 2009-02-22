Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 176786B00AD
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:27:05 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] add mutex and hibernation notifier to memory hotplug.
Date: Mon, 23 Feb 2009 00:26:33 +0100
References: <20081106153444.33af7019.kamezawa.hiroyu@jp.fujitsu.com> <20090222223547.GH26999@elf.ucw.cz>
In-Reply-To: <20090222223547.GH26999@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902230026.35284.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, gerald.schaefer@de.ibm.com, ncunningham@crca.org.au, Dave Hansen <dave@linux.vnet.ibm.com>, Tolentino <matthew.e.tolentino@intel.com>, Hansen <haveblue@us.ibm.com>, linux-pm@lists.osdl.org, Matt@smtp1.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave@smtp1.linux-foundation.org, Mel Gorman <mel@skynet.ie>, Andy@smtp1.linux-foundation.org, Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sunday 22 February 2009, Pavel Machek wrote:
> Hi!
> 
> > Sorry, I can't test this now but I post this while discussion is hot.
> > 
> > I'll test this with CONFIG_PM_DEBUG's hibernation test mode if I can.
> > (But may take a long time..) 
> > 
> > Any feedback is welcome.
> 
> I lost the track here... but this may still be required... ? And given
> that there will be both mem hotplug and swsusp in SLE11...

I think the patch would be helpful, but I've lost it somethow.  I'll try to dig
it out in my e-mail archives.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
