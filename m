Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB176B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 22:58:53 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so200203692pab.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 19:58:52 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ny6si10954446pab.215.2015.11.16.19.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 19:58:52 -0800 (PST)
Received: by padhx2 with SMTP id hx2so197051793pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 19:58:52 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151116214304.6fa42a4e@grimm.local.home>
Date: Tue, 17 Nov 2015 11:58:44 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <8582F660-B54A-474B-960E-CD5D0FF6428F@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com> <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz> <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com> <20151113090115.1ad4235b@gandalf.local.home> <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com> <5649ACF6.1000704@suse.cz> <20151116092501.761f31d7@gandalf.local.home> <233209B0-A466-4149-93C6-7173FF0FD4C5@gmail.com> <20151116214304.6fa42a4e@grimm.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 17, 2015, at 10:43, Steven Rostedt <rostedt@goodmis.org> wrote:
>=20
> On Tue, 17 Nov 2015 10:21:47 +0800
> yalin wang <yalin.wang2010@gmail.com> wrote:
>=20
>=20
>> i have not tried ,
>> just a question,
>> if you print a %s , but don=E2=80=99t call trace_define_field() do =
define this string in
>> __entry ,  how does user space perf tool to get this string info and =
print it ?
>> i am curious ..
>> i can try this when i have time.  and report to you .
>=20
> Because the print_fmt has nothing to do with the fields. You can have
> as your print_fmt as:
>=20
> 	TP_printk("Message =3D %s", "hello dolly!")
>=20
> And both userspace and the kernel with process that correctly (if I =
got
> string processing working in userspace, which I believe I do). The
> string is processed, it's not dependent on TP_STRUCT__entry() unless =
it
> references a field there. Which can also be used too:
>=20
> 	TP_printk("Message =3D %s", __entry->musical ? "Hello dolly!" :
> 			"Death Trap!")
>=20
> userspace will see in the entry:
>=20
> print_fmt: "Message =3D %s", REC->musical ? "Hello dolly!" : "Death =
Trap!"
>=20
> as long as the field "musical" exists, all is well.
>=20
> -- Steve
Aha,  i see.
Thanks very much for your explanation.
Better print fat is :  =20
TP_printk("mm=3D%p, scan_pfn=3D%s, writable=3D%d, referenced=3D%d, =
none_or_zero=3D%d, status=3D%s, unmapped=3D%d",
               __entry->mm,
		__entry->pfn =3D=3D (-1UL) ? "(null)" :  itoa(buff,  =
__entry->pin, 10), =E2=80=A6..)

is this possible ?

Thanks








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
