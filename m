Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] rmap 14
Date: Mon, 19 Aug 2002 21:50:33 +0200
References: <Pine.LNX.4.44.0208162247590.874-100000@skynet>
In-Reply-To: <Pine.LNX.4.44.0208162247590.874-100000@skynet>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17gsXp-0000rJ-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>, Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Bill Huey <billh@gnuppy.monkey.org>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 17 August 2002 01:02, Mel wrote:
> On Fri, 16 Aug 2002, Scott Kaplan wrote:
> The measure is the time when the script asked the module to read a page.
> The page is read by echoing to a mapanon_read proc entry. It's looking
> like it takes about 350 microseconds to enter the module and perform the
> read. I don't call schedule although it is possible I get scheduled. The only
> way to be sure would be to collect all timing information within the module
> which is perfectly possible. The only trouble is that if the module collects,
> only one test instance can run at a time.

It sounds like you want to try the linux trace toolkit:

   http://www.opersys.com/LTT/

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
