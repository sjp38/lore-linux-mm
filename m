Subject: Re: slablru for 2.5.32-mm1
From: Robert Love <rml@tech9.net>
In-Reply-To: <E17oGD4-0006lm-00@starship>
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu>
	<1031286298.940.37.camel@phantasy>  <E17oGD4-0006lm-00@starship>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 09 Sep 2002 00:36:25 -0400
Message-Id: <1031546187.15794.19.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Craig Kulesa <ckulesa@as.arizona.edu>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2002-09-08 at 17:43, Daniel Phillips wrote:

> - 		if (unlikely((condition)!=0)) BUG(); \
> + 		if (unlikely(condition)) BUG(); \

Then send in a patch; the code I pasted was the current 2.5 BUG_ON (and
2.4's, since I copied it from 2.5 when I sent the patch). ;-)

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
