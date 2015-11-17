Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9866B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:21:56 -0500 (EST)
Received: by padhx2 with SMTP id hx2so194459727pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:21:56 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ba4si54406792pbb.20.2015.11.16.18.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 18:21:55 -0800 (PST)
Received: by padhx2 with SMTP id hx2so194459470pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:21:55 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151116092501.761f31d7@gandalf.local.home>
Date: Tue, 17 Nov 2015 10:21:47 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <233209B0-A466-4149-93C6-7173FF0FD4C5@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com> <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz> <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com> <20151113090115.1ad4235b@gandalf.local.home> <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com> <5649ACF6.1000704@suse.cz> <20151116092501.761f31d7@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 16, 2015, at 22:25, Steven Rostedt <rostedt@goodmis.org> wrote:
>=20
> On Mon, 16 Nov 2015 11:16:22 +0100
> Vlastimil Babka <vbabka@suse.cz> wrote:
>>=20
>>>> -- Steve =20
>>> it is not easy to print for perf tools in userspace ,
>>> if you use this format ,
>>> for user space perf tool, it print the entry by look up the member =
in entry struct by offset ,
>>> you print a dynamic string which user space perf tool don=E2=80=99t =
know how to print this string . =20
>>=20
>> Does it work through trace-cmd?
>=20
> The two use the same code. If it works in one, it will work in the
> other.
>=20
> -- Steve
>=20
i have not tried ,
just a question,
if you print a %s , but don=E2=80=99t call trace_define_field() do =
define this string in
__entry ,  how does user space perf tool to get this string info and =
print it ?
i am curious ..
i can try this when i have time.  and report to you .

Thanks=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
