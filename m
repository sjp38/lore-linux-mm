Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
From: Paul Larson <plars@austin.ibm.com>
In-Reply-To: <1027450930.7700.26.camel@plars.austin.ibm.com>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
	<1027377273.5170.37.camel@plars.austin.ibm.com>
	<20020722225251.GG919@holomorphy.com>
	<1027446044.7699.15.camel@plars.austin.ibm.com>
	<20020723174942.GL919@holomorphy.com>
	<1027450930.7700.26.camel@plars.austin.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Jul 2002 14:57:19 -0500
Message-Id: <1027454241.7700.34.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dmccr@us.ibm.com
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

I was asking Dave McCracken and he mentioned that rmap and highmem pte
don't play nice together.  I tried turning that off and it boots without
error now.  Someone might want to take a look at getting those two to
work cleanly together especially now that rmap is in.  But for now, this
will work around the problem.

Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
