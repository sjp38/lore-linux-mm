Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 877986B005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 04:05:03 -0500 (EST)
Subject: Re: marching through all physical memory in software
From: Nigel Cunningham <ncunningham-lkml@crca.org.au>
Reply-To: ncunningham-lkml@crca.org.au
In-Reply-To: <20090128193813.GD1222@ucw.cz>
References: <497DD8E5.1040305@nortel.com>
	 <20090126075957.69b64a2e@infradead.org> <497F5289.404@nortel.com>
	 <m1vds0bj2j.fsf@fess.ebiederm.org>  <20090128193813.GD1222@ucw.cz>
Content-Type: text/plain
Date: Fri, 30 Jan 2009 20:05:24 +1100
Message-Id: <1233306324.11332.11.camel@nigel-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Chris Friesen <cfriesen@nortel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, Doug Thompson <norsk5@yahoo.com>, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, 2009-01-28 at 20:38 +0100, Pavel Machek wrote:
> You can do the scrubbing today by echo reboot > /sys/power/disk; echo
> disk > /sys/power/state :-)... or using uswsusp APIs.

That won't work. The RAM retains it's contents across a reboot, and even
for a little while after powering off.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
