Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 029EA6B0092
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:17:37 -0400 (EDT)
Received: by lagz14 with SMTP id z14so4793531lag.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 11:17:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <12701333991475@webcorp7.yandex-team.ru>
References: <37371333672160@webcorp7.yandex-team.ru>
	<4F7E9854.1020904@gmail.com>
	<12701333991475@webcorp7.yandex-team.ru>
Date: Mon, 9 Apr 2012 11:17:35 -0700
Message-ID: <CALWz4ixcXXPU_=vqcsH1uLkG8jsL+4yP0oLhhHvnNdMa6pzZQw@mail.gmail.com>
Subject: Re: mapped pagecache pages vs unmapped pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Ivanov <rbtz@yandex-team.ru>
Cc: "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Mon, Apr 9, 2012 at 10:11 AM, Alexey Ivanov <rbtz@yandex-team.ru> wrote:
> Thanks for the hint!
>
> Can anyone clarify the reason of not using zone->inactive_ratio in inacti=
ve_file_is_low_global()?

anonymous pages starts out referenced in active list, and scanning the
whole active list will only rotate those pages. So we would like to
limit the size of inactive anon to save scanning.

--Ying


>
> 06.04.2012, 11:16, "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com=
>:
>> On 04/06/2012 08:29 AM, Alexey Ivanov wrote:
>>
>>> =A0In progress of migration from FreeBSD to Linux and we found some str=
ange behavior: periodically running tasks (like rsync/p2p deployment) evict=
 mapped pages from memory.
>>>
>>> =A0From my little research I've found following lkml thread:
>>> =A0https://lkml.org/lkml/2008/6/11/278
>>> =A0And more precisely this commit: https://git.kernel.org/?p=3Dlinux/ke=
rnel/git/torvalds/linux-2.6.git;a=3Dcommit;h=3D4f98a2fee8acdb4ac84545df98cc=
cecfd130f8db
>>> =A0which along with splitting LRU into "anon" and "file" removed suppor=
t of reclaim_mapped.
>>>
>>> =A0Is there a knob to prioritize mapped memory over unmapped (without m=
odifying all apps to use O_DIRECT/fadvise/madvise or mlocking our data in m=
emory) or at least some way to change proportion of Active(file)/Inactive(f=
ile)?
>>
>> Hi Alexey,
>>
>> Cc to linux-mm mailing list.
>>
>> I have met the similar problem and I have sent a mail to discuss it.
>> Maybe it can help you
>> (http://marc.info/?l=3Dlinux-mm&m=3D132947026019538&w=3D2).
>>
>> Now Konstantin has sent a patch set to try to expand vm_flags from 32
>> bit to 64 bit. =A0Then we can add the new flag into vm_flags and
>> prioritize mmaped pages in madvise(2).
>>
>> Regards,
>> Zheng
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> Alexey Ivanov
> Yandex Search Admin Team
> *************
> tel.: +7 (985) 120-35-83 (int. 7176)
> http://staff.yandex-team.ru/rbtz
> *************
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
