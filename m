Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] rmap 14
Date: Mon, 19 Aug 2002 23:38:21 +0200
References: <Pine.LNX.4.44.0208192204260.23261-100000@skynet>
In-Reply-To: <Pine.LNX.4.44.0208192204260.23261-100000@skynet>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17guEA-0000vQ-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 19 August 2002 23:19, Mel wrote:
> On Mon, 19 Aug 2002, Daniel Phillips wrote:
> 
> > It sounds like you want to try the linux trace toolkit:
> >
> >    http://www.opersys.com/LTT/
> >
> 
> I have been looking it's direction a couple of times. I suspect I'll
> eventually end up using it to answer some questions

That's exactly what I meant - when you uncover something interesting with
your test tool, you investigate it further with LTT.

> but I'm trying to
> get as far as possible without using large kernel patches. At the moment
> the extent of the patches involves exporting symbols to modules

I think you've chosen roughly the right level to approach this.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
