Message-ID: <3F61D322.7020507@nortelnetworks.com>
Date: Fri, 12 Sep 2003 10:07:30 -0400
From: Chris Friesen <cfriesen@nortelnetworks.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com> <3F614912.3090801@genebrew.com> <3F614C1F.6010802@nortelnetworks.com> <20030912111808.GA13973@hh.idb.hist.no>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Rahul Karnik <rahul@genebrew.com>, rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Helge Hafting wrote:
> On Fri, Sep 12, 2003 at 12:31:27AM -0400, Chris Friesen wrote:

> Note that this "memory" is RAM+swap.  So you can avoid allocation
> failure by giving your strict overcommit box much more swap space.

This works great for the desktop, doesn't work so well when you don't 
have any swap--as is the case for most embedded apps that would like 
stricter overcommit.

Chris



-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
