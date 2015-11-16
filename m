Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0249D6B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:25:05 -0500 (EST)
Received: by igcph11 with SMTP id ph11so57822823igc.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:25:04 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0241.hostedemail.com. [216.40.44.241])
        by mx.google.com with ESMTP id h185si11006518ioh.207.2015.11.16.06.25.04
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 06:25:04 -0800 (PST)
Date: Mon, 16 Nov 2015 09:25:01 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
Message-ID: <20151116092501.761f31d7@gandalf.local.home>
In-Reply-To: <5649ACF6.1000704@suse.cz>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
	<20151112092923.19ee53dd@gandalf.local.home>
	<5645BFAA.1070004@suse.cz>
	<D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
	<20151113090115.1ad4235b@gandalf.local.home>
	<2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com>
	<5649ACF6.1000704@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: yalin wang <yalin.wang2010@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 16 Nov 2015 11:16:22 +0100
Vlastimil Babka <vbabka@suse.cz> wrote:
>
> >> -- Steve =20
> > it is not easy to print for perf tools in userspace ,
> > if you use this format ,
> > for user space perf tool, it print the entry by look up the member in e=
ntry struct by offset ,
> > you print a dynamic string which user space perf tool don=E2=80=99t kno=
w how to print this string . =20
>=20
> Does it work through trace-cmd?

The two use the same code. If it works in one, it will work in the
other.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
