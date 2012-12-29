Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4E6096B0068
	for <linux-mm@kvack.org>; Sat, 29 Dec 2012 02:22:15 -0500 (EST)
Received: by mail-oa0-f48.google.com with SMTP id h2so10245655oag.7
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 23:22:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DC7287.1080302@yahoo.ca>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
	<535932623.34838584.1356410331076.JavaMail.root@redhat.com>
	<CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
	<50DC7287.1080302@yahoo.ca>
Date: Sat, 29 Dec 2012 15:22:14 +0800
Message-ID: <CAJd=RBB-Q21KDiNqWV6+2-e8+t=Udirsrv50A+_KAPg2mrywOg@mail.gmail.com>
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Xu <alex_y_xu@yahoo.ca>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Dec 28, 2012 at 12:08 AM, Alex Xu <alex_y_xu@yahoo.ca> wrote:
> On 25/12/12 07:05 AM, Hillf Danton wrote:
>> On Tue, Dec 25, 2012 at 12:38 PM, Zhouping Liu <zliu@redhat.com> wrote:
>>> Hello all,
>>>
>>> I found the below kernel bug using latest mainline(637704cbc95),
>>> my hardware has 2 numa nodes, and it's easy to reproduce the issue
>>> using LTP test case: "# ./mmap10 -a -s -c 200":
>>
>> Can you test with 5a505085f0 and 4fc3f1d66b1 reverted?
>>
>> Hillf
>>
>
> (for people from mailing lists, please cc me when replying)
>
> Same thing?

Yes and thank you very much for reporting it.

Hillf
>
> mapcount 0 page_mapcount 1
> ------------[ cut here ]------------
> kernel BUG at mm/huge_memory.c:1798!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
