Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC6056B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 08:21:44 -0500 (EST)
References: <1293020757.1998.2.camel@localhost.localdomain> <AANLkTin6GMiXHuoVzNWPcj0jXDqWyfWCwW9fd-v=pq=X@mail.gmail.com> <20101222190621.GA16046@balbir.in.ibm.com>
In-Reply-To: <20101222190621.GA16046@balbir.in.ibm.com>
Mime-Version: 1.0 (iPod Mail 8C148)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <EF4E1E75-4D88-4D65-9ACB-69390FDF4C18@m3y3r.de>
From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: 2.6.37-rc7: NULL pointer dereference
Date: Thu, 23 Dec 2010 14:21:27 +0100
Sender: owner-linux-mm@kvack.org
To: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Am 22.12.2010 um 20:06 schrieb Balbir Singh <balbir@linux.vnet.ibm.com>:

> Thanks for the report, does this happen at bootup?

I tried to manually upgrade systemd-10 on Fedora 14 to systemd-15. The above=
 error occured after the installation, while trying to reboot the computer. S=
adly I needed to revert to systemd-10 because of SELinux policy problems.

With kind regards
Thomas=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
