Received: by wa-out-1112.google.com with SMTP id j37so1708212waf.22
        for <linux-mm@kvack.org>; Sat, 04 Oct 2008 23:00:49 -0700 (PDT)
Message-ID: <2f11576a0810042300t26b3556ax304771b4f893468@mail.gmail.com>
Date: Sun, 5 Oct 2008 15:00:49 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Report the pagesize backing a VMA in /proc/pid/maps
In-Reply-To: <20081004221339.GA20175@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie>
	 <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
	 <20081004221339.GA20175@x200.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

>> This patch adds a new field for hugepage-backed memory regions to show the
>> pagesize in /proc/pid/maps.  While the information is available in smaps,
>> maps is more human-readable and does not incur the cost of calculating Pss. An
>> example of a /proc/self/maps output for an application using hugepages with
>> this patch applied is;
>>
>> 08048000-0804c000 r-xp 00000000 03:01 49135      /bin/cat
>> 0804c000-0804d000 rw-p 00003000 03:01 49135      /bin/cat
>> 08400000-08800000 rw-p 00000000 00:10 4055       /mnt/libhugetlbfs.tmp.QzPPTJ (deleted) (hpagesize=4096kB)
>
>> To be predictable for parsers, the patch adds the notion of reporting on VMA
>> attributes by appending one or more fields that look like "(attribute)". This
>> already happens when a file is deleted and the user sees (deleted) after the
>> filename. The expectation is that existing parsers will not break as those
>> that read the filename should be reading forward after the inode number
>> and stopping when it sees something that is not part of the filename.
>> Parsers that assume everything after / is a filename will get confused by
>> (hpagesize=XkB) but are already broken due to (deleted).
>
> Looks like procps will start showing hpagesize tag as a mapping name
> (apologies for pasting crappy code):

Administrator expect mapping name is just file name when vma is
hugepage via mmap.
So, I feel Mel's code is nicer.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
