Received: from gatekeeper.tait.co.nz (localhost.localdomain [127.0.0.1])
	by gatekeeper.tait.co.nz (8.11.2/8.9.3) with ESMTP id g88MLQH28433
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 10:21:26 +1200
Date: Mon, 09 Sep 2002 10:21:24 +1200 (NZST)
From: John Carter <john.carter@tait.co.nz>
Subject: RE: meminfo or Rephrased helping the Programmer's help themselves...
In-reply-to: <HBEHIIBBKKNOBLMPKCBBOEIKFFAA.znmeb@aracnet.com>
Message-id: <Pine.LNX.4.44.0209090937390.421-100000@parore>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M. Edward Borasky" <znmeb@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, M. Edward Borasky wrote:

> Yes, it is a high-level proposal - I adhere to the top-down philosophy of
> software design, as well as the SEI standards for software engineering
> process. One does not communicate about large software objects like the
> Linux kernel in small manageable chunks of C code in that process. Perhaps
> the fact that I insist on a design specification, requirements documents,
> code reviews, etc., is the reason nobody has volunteered to join the
> project.

Ah. Culture shock.

The kernel development I have seen that worked and got in was of the 
"Show me the code" variety. ie. What gets into the kernel and attracts 
developers is not requirement specs and design documents, it is nifty 
code that mostly works.

First some comments on your Cougar web page...

a) There is one graphical tool that does a lot. Procmeter.

b) The plethora of tools for the task is a feature not a bug. The Unix 
design philosphy is to produce tools that do one job well. The result is a 
flock of single purpose tools that you can glue together via a scripting 
language as needed.

c) R. Love it. I wrote a largish program in it that had nary a single loop 
in it. Boggled the minds of my co-workers but it was really neat clean 
good code.

d) ODBC. Hate it. It is a fundamentally broken spec. I looked at it in
detail a few years back, I can't remember the details, just the
conclusion. Very Microsoftish and broken and a pig to create a server for.  
Maybe it has changed some in the intervening years (Ah yes, it is all
coming back to me, each client needed a database specific backend. ie.
There wasn't (at that stage) a database neutral "over-the-wire" protocol,
so you had to create both a server and a client stub. It would have been
so easy to define a db neutral over the wire protocol and a single client
stub. Instead you have to load a ODBC client for every type and version of
database you want to talk to.)

Anyway, serving ODBC is perhaps not your intent. Do you intend serving
ODBC or merely using a client to stuff data into Postgres or MySql?

e) Cougar would use the infrastructure that I need. Perhaps here is common 
ground. What is needed is a good clean _simple_ API to get the data out of 
the kernel. A requirements and design exercise on that would not go amiss. 

It is _vital_ that the API be simple to use, cheap in CPU cycles, simple 
to implement. I would recommend it be phased, a _simple_ first pass and a 
second more complex version and the design be such that no change need be 
made to the initial api. (Why? Some of the stuff you want will probably be 
hairier than most need, and hairy to implement. Project could easily get 
stuck. Remember, "Show me the code", we would need to get something nifty 
and tasty to attract interest and get it in the kernel.

I'm game for making input into such a requirement & design doc of that 
limited scope.

Once we have that we can look to see how to implement.

> The first task that needs to be done is to develop a high-level model of the
> Linux kernel.

Perhaps for Cougar. But for my interest and involvement the first thing is 
a simple, well thought out API to get the data we both need out of the 
kernel.

I will invest some thought in that and come up with an RFC. Will you 
please send me a list of the sort of info that you need out of the kernel. 
I will try sort it into 
  * Can be done in userland.
  * Needed from kernel.
  * Needed from kernel, but too hairy for first phase.


-- 


John Carter                             Phone : (64)(3) 358 6639
Tait Electronics                        Fax   : (64)(3) 359 4632
PO Box 1645 Christchurch                Email : john.carter@tait.co.nz
New Zealand

Good Ideas:
Ruby                 - http://www.ruby-lang-org - The best of perl,python,scheme without the pain.
Valgrind             - http://developer.kde.org/~sewardj/ - memory debugger for x86-GNU/Linux
Free your books      - http://www.bookcrossing.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
