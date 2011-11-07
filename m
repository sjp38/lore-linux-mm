Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59B5F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 17:38:20 -0500 (EST)
Received: by ggnh4 with SMTP id h4so7541489ggn.14
        for <linux-mm@kvack.org>; Mon, 07 Nov 2011 14:38:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EB8586B.5060804@jp.fujitsu.com>
References: <1320614101.3226.5.camel@offbook> <20111107112952.GB25130@tango.0pointer.de>
 <1320675607.2330.0.camel@offworld> <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
 <20111107143010.GA3630@tango.0pointer.de> <4EB8586B.5060804@jp.fujitsu.com>
From: Kay Sievers <kay.sievers@vrfy.org>
Date: Mon, 7 Nov 2011 23:37:56 +0100
Message-ID: <CAPXgP118CzaTuV-kABfEC-D-+K75zdKVwbaYba+FuN7umJO4kA@mail.gmail.com>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mzxreary@0pointer.de, alan@lxorguk.ukuu.org.uk, dave@gnu.org, hch@infradead.org, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 7, 2011 at 23:15, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> (11/7/2011 6:30 AM), Lennart Poettering wrote:

> If you want per-user limitation, RLIMIT is bad idea. RLIMIT is only inherited
> by fork. So, The api semantics clearly mismatch your usecase.

Like RLIMIT_NPROC?

> Instead, I suggest to implement new sysfs knob.

Where would users show up in sysfs?

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
