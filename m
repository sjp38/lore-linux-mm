Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: slablru for 2.5.32-mm1
Date: Mon, 9 Sep 2002 07:10:22 +0200
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu> <E17oGD4-0006lm-00@starship> <1031546187.15794.19.camel@phantasy>
In-Reply-To: <1031546187.15794.19.camel@phantasy>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oGoZ-0006mE-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Craig Kulesa <ckulesa@as.arizona.edu>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Monday 09 September 2002 06:36, Robert Love wrote:
> On Sun, 2002-09-08 at 17:43, Daniel Phillips wrote:
> 
> > - 		if (unlikely((condition)!=0)) BUG(); \
> > + 		if (unlikely(condition)) BUG(); \
> 
> Then send in a patch; the code I pasted was the current 2.5 BUG_ON (and
> 2.4's, since I copied it from 2.5 when I sent the patch). ;-)

Actually, I dimly recall there was a reason for that awkward looking
construct, in which case the bug is a documentation bug.  Anybody
remember?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
