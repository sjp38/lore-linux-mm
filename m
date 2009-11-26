Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EA7946B004D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 13:38:29 -0500 (EST)
Received: by fxm9 with SMTP id 9so918547fxm.10
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:38:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B0EB4B6.5000702@free.fr>
References: <cover.1259248846.git.kirill@shutemov.name>
	 <4B0EB4B6.5000702@free.fr>
Date: Thu, 26 Nov 2009 20:38:27 +0200
Message-ID: <cc557aab0911261038y63ee617oad5198d04cc38aca@mail.gmail.com>
Subject: Re: [PATCH RFC v0 0/3] cgroup notifications API and memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 7:02 PM, Daniel Lezcano <daniel.lezcano@free.fr> wr=
ote:
> Kirill A. Shutemov wrote:
>>
>> It's my first attempt to implement cgroup notifications API and memory
>> thresholds on top of it. The idea of API was proposed by Paul Menage.
>>
>> It lacks some important features and need more testing, but I want publi=
sh
>> it as soon as possible to get feedback from community.
>>
>> TODO:
>> =C2=A0- memory thresholds on root cgroup;
>> =C2=A0- memsw support;
>> =C2=A0- documentation.
>>
>
> Maybe it would be interesting to do that for the /cgroup/<name>/tasks by
> sending in the event the number of tasks in the cgroup when it changes, s=
o
> it more easy to detect 0 process event and then remove the cgroup directo=
ry,
> no ?

I'll do it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
