Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E722D6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 19:33:49 -0500 (EST)
Message-ID: <4EB878F3.1040508@jp.fujitsu.com>
Date: Mon, 07 Nov 2011 19:33:55 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] tmpfs: support user quotas
References: <1320614101.3226.5.camel@offbook> <20111107112952.GB25130@tango.0pointer.de> <1320675607.2330.0.camel@offworld> <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk> <20111107143010.GA3630@tango.0pointer.de> <4EB8586B.5060804@jp.fujitsu.com> <CAPXgP118CzaTuV-kABfEC-D-+K75zdKVwbaYba+FuN7umJO4kA@mail.gmail.com>
In-Reply-To: <CAPXgP118CzaTuV-kABfEC-D-+K75zdKVwbaYba+FuN7umJO4kA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kay.sievers@vrfy.org
Cc: mzxreary@0pointer.de, alan@lxorguk.ukuu.org.uk, dave@gnu.org, hch@infradead.org, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(11/7/2011 5:37 PM), Kay Sievers wrote:
> On Mon, Nov 7, 2011 at 23:15, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> (11/7/2011 6:30 AM), Lennart Poettering wrote:
> 
>> If you want per-user limitation, RLIMIT is bad idea. RLIMIT is only inherited
>> by fork. So, The api semantics clearly mismatch your usecase.
> 
> Like RLIMIT_NPROC?

I suggest to don't follow useless interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
