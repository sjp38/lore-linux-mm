Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id DD7D96B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 06:35:07 -0400 (EDT)
Message-ID: <1335868497.13683.123.camel@twins>
Subject: Re: [PATCH RFC v2] lib: Proportions with flexible period
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 01 May 2012 12:34:57 +0200
In-Reply-To: <1335285033-7347-2-git-send-email-jack@suse.cz>
References: <1335285033-7347-1-git-send-email-jack@suse.cz>
	 <1335285033-7347-2-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 2012-04-24 at 18:30 +0200, Jan Kara wrote:
> Implement code computing proportions of events of different type (like co=
de in
> lib/proportions.c) but allowing periods to have different lengths. This a=
llows
> us to have aging periods of fixed wallclock time which gives better propo=
rtion
> estimates given the hugely varying throughput of different devices - prev=
ious
> measuring of aging period by number of events has the problem that a reas=
onable
> period length for a system with low-end USB stick is not a reasonable per=
iod
> length for a system with high-end storage array resulting either in too s=
low
> proportion updates or too fluctuating proportion updates.


OK, seems sound. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
