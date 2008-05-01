From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <19857914.1209630989615.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 May 2008 17:36:29 +0900 (JST)
Subject: Re: Re: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <1209602058.27240.4.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1209602058.27240.4.camel@badari-desktop>
 <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
	 <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	 <20080422045205.GH21993@wotan.suse.de>
	 <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080422094352.GB23770@wotan.suse.de>
	 <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
	 <20080423004804.GA14134@wotan.suse.de>
	 <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080430065611.GH27652@wotan.suse.de>
	 <20080430001249.c07ff5c8.akpm@linux-foundation.org>
	 <20080430072620.GI27652@wotan.suse.de>
	 <28073963.1209598183931.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Thu, 2008-05-01 at 08:29 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
>> >
>> >One issue that I am still not clear on is (in particular for memory 
>> >offline) is how exactly to determine if a page is under read I/O. I 
>> >initially thought simply checking for PageUptodate would do the trick.
>> >
>> All troublesome case I found was "write". In my understanding,
>> at generic bufferted file write, xxx_write_begin() -> write -> xxx_write_en
d()
>>  sequence is used. xxx_write_begin locks a page and xxx_write_end unlock it
. 
>> (and xxx_write_end() set a page to be Uptodate in usual case.)
>> So,it seems we can depend on that a page is locked or not.
>
>You can wait for PG_writeback to be cleared to wait for IO to finish.
 
yes, and migraion(offline) doesn't handle PG_writback page. it waits.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
