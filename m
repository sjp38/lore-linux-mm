Date: Wed, 18 Oct 2000 11:15:19 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: OOM Test Case - Failed!
Message-ID: <20001018111519.B840@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.21.0010170958530.637-100000@winds.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010170958530.637-100000@winds.org>; from gandalf@winds.org on Tue, Oct 17, 2000 at 10:02:52AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 17, 2000 at 10:02:52AM -0400, Byron Stanoszek wrote:
> I am very unimpressed with the current OOM killer. 
[...]
> We need to decide on a better algorithm,
> albeit simple, that will alleviate this problem before 2.4.0 final comes out.

We don't need to decide on one, you can provide and install your
own, if your apply my oom-killer-api-patch.

It's at: http://www.tu-chemnitz.de/~ioe/oom_kill_api.patch

PS: Removed Linus from CC, because every change of MM has to be
   approved by Rik first. Added linux-mm, because it's an MM issue.

PPS: We had an controversal discussion at linux-mm about this
   last week. So look into the archives.

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
