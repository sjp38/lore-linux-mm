Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B33146B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 23:13:15 -0500 (EST)
Received: by qadz32 with SMTP id z32so706074qad.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 20:13:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F47E0D0.9030409@fb.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
	<CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
	<4F468888.9090702@fb.com>
	<20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
	<CAKTCnzk7TgDeYRZK0rCugopq0tO7BtM8jM9U0RJUTqNtz42ZKw@mail.gmail.com>
	<4F47E0D0.9030409@fb.com>
Date: Sat, 25 Feb 2012 09:43:14 +0530
Message-ID: <CAKTCnznyZGLiZPNS151GzsUMApN_SYu3n6xX9E0ceMpq9JNq7w@mail.gmail.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat, Feb 25, 2012 at 12:41 AM, Arun Sharma <asharma@fb.com> wrote:
> On 2/24/12 6:51 AM, Balbir Singh wrote:
>>
>> On Fri, Feb 24, 2012 at 8:17 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> =A0wrote:
>>>>
>>>> They don't have access to each other's VMAs, but if "accidentally" one
>>>> of them comes across an uninitialized page with data from another task=
,
>>>> it's not a violation of the security model.
>>
>>
>> Can you expand more on the single address space model?
>
>
> I haven't thought this through yet. But I know that just adding
>
> && (cgroup_task_count() =3D=3D 1)
>
> to page_needs_clearing() is not going to do it. We'll have to design a ne=
w
> mechanism (cgroup_mm_count_all()?) and make sure that it doesn't race wit=
h
> fork() and inadvertently expose pages from the new address space to the
> existing one.
>
> A uid based approach such as the one implemented by Davide Libenzi
>
> http://thread.gmane.org/gmane.linux.kernel/548928
> http://thread.gmane.org/gmane.linux.kernel/548926
>
> would probably apply the optimization to more use cases - but conceptuall=
y a
> bit more complex. If we go with this more relaxed approach, we'll have to
> design a race-free cgroup_uid_count() based mechanism.

Are you suggesting all processes with the same UID should have access
to each others memory contents?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
