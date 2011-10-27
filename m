Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DDC076B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 17:44:41 -0400 (EDT)
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Avi Miller <avi.miller@oracle.com>
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Date: Fri, 28 Oct 2011 08:44:17 +1100
Content-Transfer-Encoding: quoted-printable
Message-Id: <4F63081B-84E7-4FF8-8920-5AF4B73895D1@oracle.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

Hi Linus et al,

If further support is required:

On 28/10/2011, at 5:52 AM, Dan Magenheimer wrote:

> Linux kernel distros incorporating frontswap:
> - Oracle UEK 2.6.39 Beta:

I have been testing this kernel for a while now as well and is =
performing well. I have tested Xen HVM, HVPVM and PVM guests all with =
tmem enabled. Automated testing is scheduled to go into our test farm =
(that runs ~80,000 hours of QA of testing of Oracle products on Oracle =
Linux per day) soon.

> - OracleVM since 2.2 (2009)

Likewise. We are planning to incorporate Transcendent Memory support =
into future Oracle VM 3.0 releases as support functionality, i.e. that =
this will be enabled on a per-server/per-guest basis so that guests are =
capable of reducing memory footprint. We see this as a critical feature =
to compete with other hypervisor's memory sharing/de-duplication =
functionality.

Thanks,
Avi

---
Oracle <http://www.oracle.com>
Avi Miller | Principal Program Manager | +61 (412) 229 687
Oracle Linux and Virtualization
417 St Kilda Road, Melbourne, Victoria 3004 Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
