Date: Thu, 07 Nov 2002 10:45:27 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.46-mm1
Message-ID: <4057974659.1036665927@[10.10.2.3]>
In-Reply-To: <3DCA9F50.1A9E5EC5@digeo.com>
References: <3DCA9F50.1A9E5EC5@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Bill Davidsen <davidsen@tmr.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > For what it's worth, the last mm kernel which booted on my old P-II IDE
>> > test machine was 44-mm2. With 44-mm6 and this one I get an oops on boot.
>> > Unfortunately it isn't written to disk, scrolls off the console, and
>> > leaves the machine totally dead to anything less than a reset. I will try
>> 
>> Any chance of setting up a serial console? They're very handy for
>> things like this ...
> 
> "vga=extended" gets you 50 rows, which is usually enough.

Depends if it keeps booting afterwards, or your pen skills are
just bad (like mine ;-))

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
