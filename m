Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 237C36B0143
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 07:12:29 -0400 (EDT)
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
	 <1253256805.4959.8.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
	 <1253260528.4959.13.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
	 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
	 <4AB487FD.5060207@cs.helsinki.fi>
	 <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
Date: Mon, 21 Sep 2009 14:12:30 +0300
Message-Id: <1253531550.5216.32.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: ngupta@vflare.org, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Mon, 2009-09-21 at 12:07 +0100, Hugh Dickins wrote:
> Is the main basis for your disgust at the way that Nitin installs the
> callback, that loop down the swap_info_structs?  I should point out
> that it was I who imposed that on Nitin: before that he was passing a
> swap entry (or was it a swap type extracted from a swap entry?
> I forget), which was the sole reference to a swp_entry_t in his
> driver - I advised a bdev interface.

The callback setup from ->read() just looks gross. However, it's your
call Hugh so I'll just shut up now. ;-)

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
