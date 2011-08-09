Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BEA656B016B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 03:06:54 -0400 (EDT)
Message-ID: <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net>
In-Reply-To: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
Date: Tue, 9 Aug 2011 00:06:53 -0700
Subject: Re: running of out memory => kernel crash
From: "Randy Dunlap" <rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>, linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, August 8, 2011 11:53 pm, Mahmood Naderan wrote:
> Hi
> I have noticed that when the swap is disabled
>
> (either via swapoff or not defining any swap partition),
>
> then running out of memory can cause a kernel panic. 
>
> I wonder why the hungry application won't be killed
>
> upon a request for a resource that is not available?
> In that case, the problematic application will be killed
> only but what we see now is that the whole system is
> crashed.

Do you have any kernel log panic/oops/Bug messages?

[adding linux-mm mailing list]


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
