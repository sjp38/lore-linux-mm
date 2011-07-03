Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 88DD36B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 13:16:36 -0400 (EDT)
Date: Sun, 3 Jul 2011 19:16:26 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/7] fault-injection: notifier error injection
Message-ID: <20110703171626.GG21127@elf.ucw.cz>
References: <1309702581-16863-1-git-send-email-akinobu.mita@gmail.com>
 <1309702581-16863-4-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1309702581-16863-4-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Greg Kroah-Hartman <gregkh@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-pm@lists.linux-foundation.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org


> +	for (action = enb->actions; action->name; action++) {
> +		struct dentry *file = debugfs_create_int(action->name, mode,
> +						enb->dir, &action->error);
> +
> +		if (!file) {
> +			debugfs_remove_recursive(enb->dir);
> +			return -ENOMEM;
> +		}

Few lines how this work would be welcome...?
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
