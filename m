From: Michael Frank <mhf@linuxmail.org>
Subject: Re: 2.6.0-test4-mm6
Date: Fri, 5 Sep 2003 17:32:33 +0800
References: <20030905015927.472aa760.akpm@osdl.org>
In-Reply-To: <20030905015927.472aa760.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200309051732.33529.mhf@linuxmail.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nigel Cunningham <ncunningham@clear.net.nz>, swsusp-devel-request@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Friday 05 September 2003 16:59, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test4/2
>.6.0-test4-mm6/
>
>
> This is only faintly tested.  It's mainly a syncup with people..
>
> . Initial support for kgdb-over-ethernet.  Mainly from Robert Walsh, based
>   on work by San Mehat.
>
>   It's pretty simple to use - read Documentation/i386/kgdb/kgdbeth.txt
>   carefully.
>
>   This uses the same ethernet driver hooks as netconsole, and is designed
>   to work alongside netconsole.
>
>   Currently it "supports" e100, eepro100, 3c59x, tlan and tulip.  Only e100
>   has been tested.

This is cute, Nigel can then debug swsusp in 2.6 via the internet while I sleep...

Regards
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
