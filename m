Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 257766B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:13:42 -0400 (EDT)
Received: by fxm18 with SMTP id 18so7408661fxm.14
        for <linux-mm@kvack.org>; Wed, 25 May 2011 05:13:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110525092449.GJ14556@legolas.emea.dhcp.ti.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com> <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
 <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com> <20110525092449.GJ14556@legolas.emea.dhcp.ti.com>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Wed, 25 May 2011 08:13:20 -0400
Message-ID: <BANLkTimd_CmVzJP1yDkuNSS+PSRk=0W_uA@mail.gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbi@ti.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 25, 2011 at 05:24, Felipe Balbi wrote:
> On Tue, May 24, 2011 at 01:10:42PM -0400, Mike Frysinger wrote:
>> latest tree seems to only fail for me now on the musb driver. =C2=A0i ca=
n
>> send out a patch later today if no one else has gotten to it yet.
>
> please do send out, but what was the compile breakage with musb ?

i logged it earlier in the thread:
drivers/usb/musb/musb_core.c: In function 'musb_write_fifo':
drivers/usb/musb/musb_core.c:219: error: implicit declaration of
function 'prefetch'
make[3]: *** [drivers/usb/musb/musb_core.o] Error 1

patch sent out now
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
