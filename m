Message-ID: <41DB2DB7.80101@sgi.com>
Date: Tue, 04 Jan 2005 17:58:47 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <20050104133051.569E.YGOTO@us.fujitsu.com>
In-Reply-To: <20050104133051.569E.YGOTO@us.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
> Hello Ray-san.
> 
> 
>>>I've been unable to get (either) memory hotplug patch to compile.  It won't
>>>compile for Altix at all, because Altix requires NUMA.  I tried it on a
>>>Pentium machine, but apparently I didn't grab the correct config.
>>
>>Hmmm.  Did you check the configs here?
>>
>>	http://sr71.net/patches/2.6.10/2.6.10-rc2-mm4-mhp3/configs/
> 
> 
> CONFIG_NUMA with memory hotplug is disabled on -mhp3,
> because some functions of memory hotplug are not defined yet and
> some works like pgdat allocation are necessary.
> .
> I posted patches for them before holidays to LHMS.
> http://sourceforge.net/mailarchive/forum.php?forum_id=223&max_rows=25&style=ultimate&viewmonth=200412
> 
> It is still for IA32. But, I would like to start works for IA64.
> I guess it won't be duplication against your works.
> But If you find something wrong, please let me know.
> 
> Bye.
> 
Hello Goto-san,

Yes, as you surmise, I am mostly interested in the page migration
patches.  I was just trying to compile the hotplug patches to make
sure my "reordering" of the hotplug patchset (putting the page
migration patches first) didn't break hotplug.

I satisifed that goal by comparing the modified files after each
version of the hotplug patch (re-ordered versus original).  Since
the files turned out basically the same, that was good enough for
now.

I'm not sure why I couldn't get the hotplug patches to compile
on i386.  I used one of Dave Hansen's suggested configs.  Anyway
the comparison above was good enough for my purposes so I didn't
pursue this any further.

Of course, we also look forward to progress in the memory hotplug
area for ia64.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
