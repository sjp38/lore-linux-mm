Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 84F5C6B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 16:56:27 -0500 (EST)
Message-ID: <4EEE6182.6070107@redfish-solutions.com>
Date: Sun, 18 Dec 2011 14:56:18 -0700
From: Philip Prindeville <philipp_subx@redfish-solutions.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] coreboot: Add support for detecting Coreboot BIOS
 signatures
References: <1324241211-7651-1-git-send-email-philipp_subx@redfish-solutions.com> <1324244805.2132.4.camel@shinybook.infradead.org>
In-Reply-To: <1324244805.2132.4.camel@shinybook.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>, Nathan Williams <nathan@traverse.com.au>, Guy Ellis <guy@traverse.com.au>, Patrick Georgi <patrick.georgi@secunet.com>, Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>, linux-mm@kvack.org

On 12/18/11 2:46 PM, David Woodhouse wrote:
> On Sun, 2011-12-18 at 13:46 -0700, Philip Prindeville wrote:
>> Add support for Coreboot BIOS detection. This in turn can be used by
>> platform drivers to verify they are running on the correct hardware,
>> as many of the low-volume SBC's (especially in the Atom and Geode
>> universe) don't always identify themselves via DMI or PCI-ID.
> It's Coreboot. So doesn't that mean we can just fix it to pass a
> device-tree to the kernel properly?
>
> Don't we only need this kind of hack for boards with crappy
> closed-source firmware?
>

Well, if we want to hold it up while someone adds device-tree support to x86... my understanding was it was PPC that used device-tree mostly at this point.

Until then, it's not clear that older platforms that are considered 'stable' are going to have new BIOS issued to their users going forward, or that any of the thousands of boards out there are going to be updated by their users.

Why not have support for existing boards that are out there?

Many of these boards are also produced by small engineering houses that aren't particularly quick to update their manufacturing processes to whatever the latest version of coreboot trunk is.

I agree that going forward, new boards coming out should support device-tree once it's stable and widely adopted, but let's not have the perfect become the enemy of the good.

-Philip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
