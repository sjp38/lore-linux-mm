Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: broken VM in 2.4.10-pre9
Date: Thu, 20 Sep 2001 13:28:31 +0200
References: <E15jpRy-0003yt-00@the-village.bc.nu>
In-Reply-To: <E15jpRy-0003yt-00@the-village.bc.nu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010920112110Z16256-2757+869@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 20, 2001 12:04 am, Alan Cox wrote:
> Reverse mappings make linear aging easier to do but are not critical (we
> can walk all physical pages via the page map array).

But you can't pick up the referenced bit that way, so no up aging, only
down.

--
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
