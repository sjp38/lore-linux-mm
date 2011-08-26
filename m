Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6D5A6B016B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 23:13:15 -0400 (EDT)
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com> <4E54BDCF.9020504@profihost.ag> <20110824093336.GB5214@localhost> <4E560F2A.1030801@profihost.ag> <20110826021648.GA19529@localhost> <4E570AEB.1040703@profihost.ag> <20110826030313.GA24058@localhost>
In-Reply-To: <20110826030313.GA24058@localhost>
Mime-Version: 1.0 (iPhone Mail 8H7)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag>
From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
Date: Fri, 26 Aug 2011 05:13:07 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>


>> There is at least a numastat proc file.
>=20
> Thanks. This shows that node0 is accessed 10x more than node1.

What can i do to prevent this or isn't this normal when a machine mostly idl=
es so processes are mostly processed by cpu0.

>=20
>> complete ps output:
>> http://pastebin.com/raw.php?i=3Db948svzN
>=20
> In that log, scp happens to be in R state and also no other tasks in D
> state. Would you retry in the hope of catching some stucked state?
Sadly not as the sysrq trigger has rebootet the machine and it will now run f=
ine for 1 or 2 days.

>=20
>>>         echo t>  /proc/sysrq-trigger
>> sadly i wa sonly able to grab the output in this crazy format:
>> http://pastebin.com/raw.php?i=3DMBXvvyH1
>=20
> It's pretty readable dmesg, except that the data is incomplete and
> there are nothing valuable in the uploaded portion..
That was everything i could grab through netconsole. Is there a better way?

Stefan
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
