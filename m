Date: Fri, 26 Jan 2001 13:22:18 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <m1itn2e0jp.fsf@frodo.biederman.org>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
	<20010123165117Z131182-221+34@kanga.kvack.org> <20010125155345Z131181-221+38@kanga.kvack.org>
	<20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com>
	<20010125175027Z131219-222+40@kanga.kvack.org> Timur Tabi's message of "Thu, 25 Jan 2001 11:53:01 -0600"
Subject: Re: ioremap_nocache problem?
Message-Id: <20010126191943Z131183-223+58@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Eric W. Biederman <ebiederm@xmission.com> on 26 Jan
2001 09:32:58 -0700


> 1) set mem=yyy where yyy = real_ram but is smaller than your device.
>    make certain your device isn't on any mtrr.

That won't work, because the BIOS will enable MTRR regardless if it sees the
RAM.  Besides, I can't set mem=yyy because the device could sit in the LOWER
memory areas, not the higher ones.  I could have two DIMMs in the computer, and
the first one could have our device.  Or, both could have our device.  Not only
that, but the interleaving will determine exactly where the device sits.

> 2) Disable SPD on your device.
>    Do the setup of the pseudo dimm yourself.

That won't work either, because I'd have to know how to program the memory
controller, and each machine is different.

Thanks for the ideas, though.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
