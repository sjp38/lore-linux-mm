Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B356B6B00BC
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 12:11:48 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id e12so397920fga.8
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 09:11:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <661de9470911260903h4996070emec678f09a7ba2c9e@mail.gmail.com>
References: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
	 <cover.1259248846.git.kirill@shutemov.name>
	 <8524ba285f6dd59cda939c28da523f344cdab3da.1259248846.git.kirill@shutemov.name>
	 <d977350fcc9bc3e1fe484440c1fc3a7470a4e26b.1259248846.git.kirill@shutemov.name>
	 <661de9470911260903h4996070emec678f09a7ba2c9e@mail.gmail.com>
Date: Thu, 26 Nov 2009 19:11:46 +0200
Message-ID: <cc557aab0911260911y577e203aha1c74a7f0f361226@mail.gmail.com>
Subject: Re: [PATCH RFC v0 3/3] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 7:03 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> On Thu, Nov 26, 2009 at 9:57 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
>> It allows to register multiple memory thresholds and gets notifications
>> when it crosses.
>>
>> To register a threshold application need:
>> - create an eventfd;
>> - open file memory.usage_in_bytes of a cgroup
>> - write string "<event_fd> <memory.usage_in_bytes> <threshold>" to
>> =C2=A0cgroup.event_control.
>>
>> Application will be notified through eventfd when memory usage crosses
>> threshold in any direction.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>>
>
> I don't see the patches attached or inlined in the emails that follow

Sorry. Resent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
