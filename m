Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2036F6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 08:42:07 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2817003bwz.38
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 05:42:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200909150745.16265.edt@aei.ca>
References: <200909100215.36350.ngupta@vflare.org>
	 <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
	 <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
	 <200909150745.16265.edt@aei.ca>
Date: Tue, 15 Sep 2009 15:42:09 +0300
Message-ID: <84144f020909150542k1d62f100ubaef3bb3b1cea592@mail.gmail.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ed Tomlinson <edt@aei.ca>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 15 September 2009 03:30:23 you wrote:
>> > So, its extremely difficult to wait for the proper fix.
>>
>> Then make ramzswap depend on !CONFIG_ARM. In any case, CONFIG_ARM bits
>> really don't belong into drivers/block.

On Tue, Sep 15, 2009 at 2:45 PM, Ed Tomlinson <edt@aei.ca> wrote:
> Problem is that ramzswap is usefull on boxes like the n800/n810... =A0So =
this is a bad
> suggestion from my POV. =A0 =A0How about a comment saying this code goes =
when the
> fix arrives???

Just put the driver in driver/staging until the issue is resolved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
