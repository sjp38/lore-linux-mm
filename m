Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB959000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 01:35:07 -0400 (EDT)
Received: by vws4 with SMTP id 4so4999120vws.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 22:35:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110703171626.GG21127@elf.ucw.cz>
References: <1309702581-16863-1-git-send-email-akinobu.mita@gmail.com>
	<1309702581-16863-4-git-send-email-akinobu.mita@gmail.com>
	<20110703171626.GG21127@elf.ucw.cz>
Date: Mon, 4 Jul 2011 14:35:04 +0900
Message-ID: <CAC5umyhKafTgUe6T2vfLupwmBwt5COj6X2nUH2b5ekhzQNi5mg@mail.gmail.com>
Subject: Re: [PATCH 3/7] fault-injection: notifier error injection
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Greg Kroah-Hartman <gregkh@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-pm@lists.linux-foundation.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

2011/7/4 Pavel Machek <pavel@ucw.cz>:
>
>> + =A0 =A0 for (action =3D enb->actions; action->name; action++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct dentry *file =3D debugfs_create_int(act=
ion->name, mode,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 enb->dir, &action->error);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!file) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove_recursive(enb->=
dir);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Few lines how this work would be welcome...?

OK, I'll add a comment like below.

/*
 * Create debugfs r/w file containing action->error. If notifier call
 * chain is called with action->val, it will fail with the error code
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
