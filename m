Date: Sun, 20 May 2001 17:32:52 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
Message-ID: <20010520173252.Q754@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.21.0105191840250.5531-100000@imladris.rielhome.conectiva> <Pine.LNX.4.33.0105200509130.488-100000@mikeg.weiden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0105200509130.488-100000@mikeg.weiden.de>; from mikeg@wen-online.de on Sun, May 20, 2001 at 05:29:49AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 20, 2001 at 05:29:49AM +0200, Mike Galbraith wrote:
> I'm not sure why that helps.  I didn't put it in as a trick or
> anything though.  I put it in because it didn't seem like a
> good idea to ever have more cleaned pages than free pages at a
> time when we're yammering for help.. so I did that and it helped.

The rationale for this is easy: free pages is wasted memory,
clean pages is hot, clean cache. The best state a cache can be in.

Regards

Ingo Oeser
-- 
To the systems programmer,
users and applications serve only to provide a test load.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
