Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D2446B014C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:08:18 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so909814fga.8
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:08:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909211244510.6209@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
	 <1253260528.4959.13.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
	 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
	 <4AB487FD.5060207@cs.helsinki.fi>
	 <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
	 <1253531550.5216.32.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909211244510.6209@sister.anvils>
Date: Mon, 21 Sep 2009 15:08:04 +0300
Message-ID: <84144f020909210508i7e8b1b3bif61dcb5b576c878d@mail.gmail.com>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: ngupta@vflare.org, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Mon, Sep 21, 2009 at 2:55 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> Though exporting the swap_info_struct still bothers me, and it
> seems convoluted that the block device should have a method, so
> swapon can call the block device, so the block device can call
> swapfile.c to install a callout, so that swapfile.c can call the
> block device when freeing swap. =A0I'm not saying there is a better
> way, just that I'd be glad of a better way.

I guess we can combine my ->swapon() hook in struct
block_device_operations with Nitin's set_swap_free_notify() function
to avoid exporting struct swap_info_struct. Alternatively, we could
add the ->swap_free() hook too struct block_device_operations. In any
case, I don't think we can do the setup at sys_open() if we keep
Nitin's hook as struct swap_info_struct is not set up until
sys_swapon().

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
