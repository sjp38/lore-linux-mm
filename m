Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.42-mm2 on small systems
Date: Wed, 16 Oct 2002 18:43:10 -0400
References: <Pine.LNX.3.96.1021016164613.12145A-100000@gatekeeper.tmr.com>
In-Reply-To: <Pine.LNX.3.96.1021016164613.12145A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210161843.10095.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On October 16, 2002 04:55 pm, Bill Davidsen wrote:
> On Mon, 14 Oct 2002, Andrew Morton wrote:
> > hm.  Works for me.  The default setting are waaay too boring, so
> > I used ./resp -m2 -M5 -w5

> This was intended to be a simple test of how the kernel feels, and it is
> that, but some kernels I've tried get to one test or another and shit the
> bed every time. It's not a stress test! How can I get my numbers if the
> kernel keeps hanging solid? ;-)

You add sufficient tracing so you can find were it hangs...  And report it
so it can get fixed.  IMHO, while not a stress test, it can put stress on
the kernel - it needs to to test the interactive response.

Still trying to figure out what is happening on my 64m 486.

Thanks for the interesting benchmark.

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
