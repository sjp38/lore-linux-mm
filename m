Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id C19796B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 12:32:38 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so4432206obc.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:32:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EEFA861.2050807@redfish-solutions.com>
References: <1324241211-7651-1-git-send-email-philipp_subx@redfish-solutions.com>
	<1324244805.2132.4.camel@shinybook.infradead.org>
	<4EEFA861.2050807@redfish-solutions.com>
Date: Wed, 21 Dec 2011 10:32:37 -0700
Message-ID: <CAKipaEoN_uCLza7U10kL0JzWSecpw5odfHaEWsG_fXMUCZ1NQA@mail.gmail.com>
Subject: Re: [PATCH 2/4] coreboot: Add support for detecting Coreboot BIOS signatures
From: Jordan Crouse <jordan@cosmicpenguin.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>, Nathan Williams <nathan@traverse.com.au>, Guy Ellis <guy@traverse.com.au>, Patrick Georgi <patrick.georgi@secunet.com>, Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>, linux-mm@kvack.org

On Mon, Dec 19, 2011 at 2:10 PM, Philip Prindeville
<philipp_subx@redfish-solutions.com> wrote:
> On 12/18/11 1:46 PM, David Woodhouse wrote:
>> On Sun, 2011-12-18 at 13:46 -0700, Philip Prindeville wrote:
>>> Add support for Coreboot BIOS detection. This in turn can be used by
>>> platform drivers to verify they are running on the correct hardware,
>>> as many of the low-volume SBC's (especially in the Atom and Geode
>>> universe) don't always identify themselves via DMI or PCI-ID.
>> It's Coreboot. So doesn't that mean we can just fix it to pass a
>> device-tree to the kernel properly?
>>
>> Don't we only need this kind of hack for boards with crappy
>> closed-source firmware?
>>
>
> How about this: we upstream the patches and as soon as I have access to a Geode-based box using a device-tree capable version of Coreboot, I'll add support...
>
> BTW: the patches themselves seem to be stalled waiting on list-owner approval... I'll see if I can get them dislodged.
>
> -Philip

I have long since forgotten the admin password and I really need to
pass on the adminship to somebody else.  Any
takers?

Jordan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
