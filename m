Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id AA2916B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 07:27:43 -0400 (EDT)
Received: by qatp27 with SMTP id p27so2313086qat.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 04:27:42 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 25 Sep 2012 19:27:42 +0800
Message-ID: <CAEkdkmVnnCCHvrFzhib_USGQGQYc7UhQjO-nTyp+RLiTXjRtGA@mail.gmail.com>
Subject: sparsemem issues
From: ss ss <nizhan.chen@gmail.com>
Content-Type: multipart/alternative; boundary=20cf303b40f395f93904ca84fe68
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, wency@cn.fujitsu.com, Bob Picco <bob.picco@hp.com>, Dave Hansen <haveblue@us.ibm.com>

--20cf303b40f395f93904ca84fe68
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

Hi all,

This is my first time send email to mm community, if something is wrong or
silly, please forgive me.
I have some confusions of sparsemem:

1. sparsemem

It seems that all mem_sections descriptors (except the second level if use
sparsemem extreme )are allocated
before memory_present, then when the are allocated ?

2. sparsemem extreme

sparsemem extreme implementation [commit : 3e347261a80b57df] changelog:

 "This two level layout scheme is able to achieve smaller memory
requirements for SPARSEMEM
  with the tradeoff of an additional shift and load when fetching the
memory section."

then how to judge when the benefit from achieve smaller memory
 requirements for SPARSEMEM
is worth with the additional shift and load when fetching the memory
section.=A3=BF

"The patch attempts isolates the implementation details of the physical
layout of the sparsemem section
 array."

but how it isolates?

3. sparsemem vmemmap

1)
 The two key operations pfn_to_page and page_to_page become:

    #define __pfn_to_page(pfn)      (vmemmap + (pfn))
    #define __page_to_pfn(page)     ((page) - vmemmap)

how can guarantee the block of memory to be used to back the virtual memory
map is start from vmemmap?

2)
in Documentation/x86/x86_64/mm.txt

Virtual memory map with 4 level page tables:

0000000000000000 - 00007fffffffffff (=3D47 bits) user space, different per =
mm
hole caused by [48:63] sign extension
ffff800000000000 - ffff80ffffffffff (=3D40 bits) guard hole
ffff880000000000 - ffffc7ffffffffff (=3D64 TB) direct mapping of all phys.
memory
ffffc80000000000 - ffffc8ffffffffff (=3D40 bits) hole
ffffc90000000000 - ffffe8ffffffffff (=3D45 bits) vmalloc/ioremap space
ffffe90000000000 - ffffe9ffffffffff (=3D40 bits) hole
ffffea0000000000 - ffffeaffffffffff (=3D40 bits) virtual memory map (1TB)
... unused hole ...
ffffffff80000000 - ffffffffa0000000 (=3D512 MB)  kernel text mapping, from
phys 0
ffffffffa0000000 - fffffffffff00000 (=3D1536 MB) module mapping space


what's the total memory of the example? why virtual memory map(1TB) is that
big ? then in x86_64 platform 4GB memory, virtual memory map will start
from what address?

Thanks,
Nizhan Chen

--20cf303b40f395f93904ca84fe68
Content-Type: text/html; charset=GB2312
Content-Transfer-Encoding: quoted-printable

Hi all,<div><br></div><div>This is my first time send email to mm community=
, if something is wrong or silly, please&nbsp;<span style=3D"background-col=
or:rgb(255,255,255);font-family:arial,sans-serif;font-size:13px;white-space=
:nowrap">forgive me.&nbsp;</span></div>
<div>I have some confusions of sparsemem:</div><div><br></div><div>1. spars=
emem</div><div><br></div><div>It seems that all mem_sections descriptors (e=
xcept the second level if use sparsemem extreme )are allocated&nbsp;</div><=
div>
before memory_present,&nbsp;then when the are allocated ?</div><div>&nbsp;<=
/div><div>2. sparsemem extreme</div><div><br></div><div>sparsemem extreme i=
mplementation [commit : 3e347261a80b57df] changelog:</div><div><br></div><d=
iv><div>
&nbsp;&quot;This two level layout scheme is able to achieve smaller&nbsp;me=
mory requirements for SPARSEMEM&nbsp;</div><div>&nbsp; with the tradeoff of=
 an additional shift&nbsp;and load when fetching the memory section.&quot;&=
nbsp;</div></div><div><br>
</div><div>then how to judge when the benefit from achieve smaller memory &=
nbsp;requirements for&nbsp;SPARSEMEM</div><div>is worth with the&nbsp;addit=
ional shift&nbsp;and load when fetching the memory section.=A3=BF&nbsp;</di=
v><div><br></div><div>&quot;The patch attempts isolates the&nbsp;implementa=
tion details of the physical layout of the sparsemem section</div>
<div>&nbsp;array.&quot;</div><div><br></div><div>but how it isolates?</div>=
<div><br></div><div>3. sparsemem vmemmap</div><div><br></div><div>1)</div><=
div><div>&nbsp;The two key operations pfn_to_page and page_to_page become:<=
/div><div>
&nbsp; &nbsp;&nbsp;</div><div>&nbsp; &nbsp; #define __pfn_to_page(pfn) &nbs=
p; &nbsp; &nbsp;(vmemmap + (pfn))</div><div>&nbsp; &nbsp; #define __page_to=
_pfn(page) &nbsp; &nbsp; ((page) - vmemmap)</div></div><div><br></div><div>=
how can guarantee the block of memory to be used to back the virtual memory=
 map is start from vmemmap?</div>
<div><br></div><div>2)<br>in Documentation/x86/x86_64/mm.txt</div><div><br>=
</div><div><div>Virtual memory map with 4 level page tables:</div><div><br>=
</div><div>0000000000000000 - 00007fffffffffff (=3D47 bits) user space, dif=
ferent per mm</div>
<div>hole caused by [48:63] sign extension</div><div>ffff800000000000 - fff=
f80ffffffffff (=3D40 bits) guard hole</div><div>ffff880000000000 - ffffc7ff=
ffffffff (=3D64 TB) direct mapping of all phys. memory</div><div>ffffc80000=
000000 - ffffc8ffffffffff (=3D40 bits) hole</div>
<div>ffffc90000000000 - ffffe8ffffffffff (=3D45 bits) vmalloc/ioremap space=
</div><div>ffffe90000000000 - ffffe9ffffffffff (=3D40 bits) hole</div><div>=
ffffea0000000000 - ffffeaffffffffff (=3D40 bits) virtual memory map (1TB)</=
div>
<div>... unused hole ...</div><div>ffffffff80000000 - ffffffffa0000000 (=3D=
512 MB) &nbsp;kernel text mapping, from phys 0</div><div>ffffffffa0000000 -=
 fffffffffff00000 (=3D1536 MB) module mapping space</div></div><div><br></d=
iv><div>
<br></div><div>what&#39;s the total memory of the example? why virtual memo=
ry map(1TB) is that big ? then in x86_64 platform 4GB memory, virtual memor=
y map will start from what address?</div><div><br></div><div>Thanks,</div>
<div>Nizhan Chen&nbsp;</div>

--20cf303b40f395f93904ca84fe68--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
