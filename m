Subject: XMM: monitor Linux MM inactive/active lists graphically
References: <01060222320301.23925@oscar>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 03 Jun 2001 13:13:51 +0200
In-Reply-To: <01060222320301.23925@oscar> (Ed Tomlinson's message of "Sat, 2 Jun 2001 22:32:03 -0400")
Message-ID: <87d78lolxs.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> writes:

> Zlatko,
> 
> Do you have your modified xmem available somewhere.  Think it might be of
> interest to a few of us.
> 
> TIA
> Ed Tomlinson <tomlins@cam.org>
> 

For some time I've been trying to make a simple, yet functional web
page to put some stuff there. But, HTML hacking and kernel hacking are
such a different beasts... :)

XMM is heavily modified XMEM utility that shows graphically size of
different Linux page lists: active, inactive_dirty, inactive_clean,
code, free and swap usage. It is better suited for the monitoring of
Linux 2.4 MM implementation than original (XMEM) utility.

Find it here:  <URL:http://linux.inet.hr/>

-- 
Zlatko

P.S. I'm gladly accepting suggestion for a simple tool that would help
in static web site creation/development. I checked genpage, htmlmake
and some other utilities but in every of them I found something that I
didn't like. Tough job, that HTML authoring.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
