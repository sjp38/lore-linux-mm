From: "M. Edward Borasky" <znmeb@aracnet.com>
Subject: RE: meminfo or Rephrased helping the Programmer's help themselves...
Date: Sun, 8 Sep 2002 20:02:42 -0700
Message-ID: <HBEHIIBBKKNOBLMPKCBBGEKFFFAA.znmeb@aracnet.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
In-reply-to: <Pine.LNX.4.44.0209090937390.421-100000@parore>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: John Carter <john.carter@tait.co.nz>
List-ID: <linux-mm.kvack.org>


M. Edward (Ed) Borasky
mailto: znmeb@borasky-research.net
http://www.pdxneurosemantics.com
http://www.meta-trading-coach.com
http://www.borasky-research.net

Coaching: It's Not Just for Athletes and Executives Any More!

-----Original Message-----
From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org]On Behalf Of
John Carter
Sent: Sunday, September 08, 2002 3:21 PM
To: M. Edward Borasky
Cc: linux-mm@kvack.org
Subject: RE: meminfo or Rephrased helping the Programmer's help
themselves...
Importance: Low


Anyway, serving ODBC is perhaps not your intent. Do you intend serving
ODBC or merely using a client to stuff data into Postgres or MySql?
I picked ODBC because R has an ODBC interface, as does Minitab and nearly
every Microsoft tool. The data will be mostly stored sequentially and
accessed by medium-to-complex queries. There is a *lot* of data if you
sample a bunch o' counters every 15 seconds or thereabouts, but there is not
the need to stick records in the middle. I do a lot of this sort of thing by
hand using Access now. Access by Windows clients is a requirement - ODBC is
one way to get that but not the only way. The main purpose of this part of
Cougar is to accumulate high-frequency performance data efficiently in a
disk database and allow queries against it. I had not thought about whether
to use Postgres, MySql or something else. The database requirements are
quite simple: capture high-frequency data in real time in binary and serve
it up with standard queries and stored procedures.


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
That sounds like a good idea. My thoughts were patterned around the Windows
"PerfMon" API. That is, a "filesystem" structure but memory resident. My
requirements:
The fundamental variable is a *counter*. Counters come in two kinds:
cumulative, like the number of I/Os performed by a disk since bootup, and
static, like the number of kilobytes in page cache. Each counter has a
name - usually something very much like the name it has in the kernel code,
a label - a brief English or other language title such as one might use on a
graph, e.g., "CPU System Jiffies", a text description - what the counter is
a count or size of (like the "Explain" field in Windows PerfMon), a unit -
milliseconds, operations, kilobytes, etc., and of course a value. Since the
destination for these counters and their differences and ratios is a table
in a database, one would need the facility to easily create, say,
comma-separated value (CSV) files from the data structure. For speed, this
"filesystem" should be in RAM and in binary. Actually, the "/dev/kmem" API
from a number of other Unices isn't all that bad; you have a name table and
offsets into a memory area. The rest of it could be quite easily added.


> The first task that needs to be done is to develop a high-level model of
the
> Linux kernel.

Perhaps for Cougar. But for my interest and involvement the first thing is
a simple, well thought out API to get the data we both need out of the
kernel.
Actually - given the counters and some thinking, it isn't all that hard to
build an *empirical* model of the kernel, which is what I'd want to have
anyhow.


I will invest some thought in that and come up with an RFC. Will you
please send me a list of the sort of info that you need out of the kernel.
I will try sort it into
  * Can be done in userland.
  * Needed from kernel.
  * Needed from kernel, but too hairy for first phase
Everything I want is in the kernel - I want to make it available on a
read-only basis to userland code. The bare minimum right now is everything
that is in /proc/stat, /proc/meminfo, the disk queuing information in
/proc/partitions, the network data (packets and bytes in and out for each
interface, error counts - the kind of thing that "netstat" produces).
.


--


John Carter                             Phone : (64)(3) 358 6639
Tait Electronics                        Fax   : (64)(3) 359 4632
PO Box 1645 Christchurch                Email : john.carter@tait.co.nz
New Zealand

Good Ideas:
Ruby                 - http://www.ruby-lang-org - The best of
perl,python,scheme without the pain.
Valgrind             - http://developer.kde.org/~sewardj/ - memory debugger
for x86-GNU/Linux
Free your books      - http://www.bookcrossing.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
