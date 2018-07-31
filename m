Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C78636B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 18:57:45 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f9-v6so12445577ioh.1
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:57:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r9-v6sor6463777jab.101.2018.07.31.15.57.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 15:57:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com> <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
From: youling 257 <youling257@gmail.com>
Date: Wed, 1 Aug 2018 06:57:23 +0800
Message-ID: <CAOzgRdbLN6MiC2Hgy3pQ9Mseh6xKcK=j5E5uzujAjAoH+R+odg@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: multipart/alternative; boundary="0000000000007c25b00572538159"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

--0000000000007c25b00572538159
Content-Type: text/plain; charset="UTF-8"

Build fingerprint:
'Android-x86/android_x86/x86:8.1.0/OPM6.171019.030.B1/cwhuang0618:userdebug/test-keys'
Revision: '0'
ABI: 'x86'
pid: 2899, tid: 2899, name: zygote >>> zygote <<<
signal 7 (SIGBUS), code 2 (BUS_ADRERR), fault addr 0xec00008
    eax 00000000 ebx f0274a40 ecx 000001e0 edx 0ec00008
    esi 00000000 edi 0ec00000
    xcs 00000023 xds 0000002b xes 0000002b xfs 00000003 xss 0000002b
    eip f24a4996 ebp ffc4eaa8 esp ffc4ea68 flags 00010202

backtrace:
    #00 pc 0001a996 /system/lib/libc.so (memset+150)
    #01 pc 0022b2be /system/lib/libart.so (create_mspace_with_base+222)
    #02 pc 002b2a05 /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateMspace(void*, unsigned int, unsigned
int)+69)
    #03 pc 002b2637 /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateFromMemMap(art::MemMap*,
std::__1::basic_string<char, std::__1::char_traits<char>,
std::__1::allocator<char>> const&, unsigned int, unsigned int, unsigned
int, unsigned int, bool)+55)
    #04 pc 0027f6af /system/lib/libart.so (art::gc::Heap::Heap(unsigned
int, unsigned int, unsigned int, unsigned int, double, double, unsigned
int, unsigned int, std::__1::basic_string<char,
std::__1::char_traits<char>, std::__1::allocator<char>> const&,
art::InstructionSet, art::gc::CollectorType, art::gc::CollectorType,
art::gc::space::LargeObjectSpaceType, unsigned int, unsigned int, unsigned
int, bool, unsigned int, unsigned int, bool, bool, bool, bool, bool, bool,
bool, bool, bool, bool, bool, unsig #05 pc 0055a17a /system/lib/libart.so
(_ZN3art7Runtime4InitEONS_18RuntimeArgumentMapE+11434)
    #06 pc 0055e928 /system/lib/libart.so
(art::Runtime::Create(std::__1::vector<std::__1::pair<std::__1::basic_string<char,
std::__1::char_traits<char>, std::__1::allocator<char>>, void const*>,
std::__1::allocator<std::__1::pair<std::__1::basic_string<char,
std::__1::char_traits<char>, std::__1::allocator<char>>, void const*>>>
const&, bool)+184)

2018-08-01 0:29 GMT+08:00 Linus Torvalds <torvalds@linux-foundation.org>:

> On Mon, Jul 30, 2018 at 11:40 PM Amit Pundir <amit.pundir@linaro.org>
> wrote:
> >
> > This ashmem change ^^ worked too.
>
> Ok, let's go for that one and hope it's the only one.
>
> John, can I get a proper commit message and sign-off for that ashmem
> change?
>
> Kirill - you mentioned that somebody reproduced a problem on x86-64
> too. I didn't see that report. Was that some odd x86 Android setup
> with Ashmem too, or is there something else pending?
>
>                        Linus
>

--0000000000007c25b00572538159
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Build fingerprint: &#39;Android-x86/android_x86/x86:8.1.0/=
OPM6.171019.030.B1/cwhuang0618:userdebug/test-keys&#39;<div>Revision: &#39;=
0&#39;</div><div>ABI: &#39;x86&#39;</div><div>pid: 2899, tid: 2899, name: z=
ygote  &gt;&gt;&gt; zygote &lt;&lt;&lt;</div><div>signal 7 (SIGBUS), code 2=
 (BUS_ADRERR), fault addr 0xec00008</div><div>=C2=A0 =C2=A0 eax 00000000  e=
bx f0274a40  ecx 000001e0  edx 0ec00008</div><div>=C2=A0 =C2=A0 esi 0000000=
0  edi 0ec00000</div><div>=C2=A0 =C2=A0 xcs 00000023  xds 0000002b  xes 000=
0002b  xfs 00000003  xss 0000002b</div><div>=C2=A0 =C2=A0 eip f24a4996  ebp=
 ffc4eaa8  esp ffc4ea68  flags 00010202</div><div><br></div><div>backtrace:=
</div><div>=C2=A0 =C2=A0 #00 pc 0001a996  /system/lib/libc.so (memset+150)<=
/div><div>=C2=A0 =C2=A0 #01 pc 0022b2be  /system/lib/libart.so (create_mspa=
ce_with_base+222)</div><div>=C2=A0 =C2=A0 #02 pc 002b2a05  /system/lib/liba=
rt.so (art::gc::space::DlMallocSpace::CreateMspace(void*, unsigned int, uns=
igned int)+69)</div><div>=C2=A0 =C2=A0 #03 pc 002b2637  /system/lib/libart.=
so (art::gc::space::DlMallocSpace::CreateFromMemMap(art::MemMap*, std::__1:=
:basic_string&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::allocat=
or&lt;char&gt;&gt; const&amp;, unsigned int, unsigned int, unsigned int, un=
signed int, bool)+55)</div><div>=C2=A0 =C2=A0 #04 pc 0027f6af  /system/lib/=
libart.so (art::gc::Heap::Heap(unsigned int, unsigned int, unsigned int, un=
signed int, double, double, unsigned int, unsigned int, std::__1::basic_str=
ing&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;char=
&gt;&gt; const&amp;, art::InstructionSet, art::gc::CollectorType, art::gc::=
CollectorType, art::gc::space::LargeObjectSpaceType, unsigned int, unsigned=
 int, unsigned int, bool, unsigned int, unsigned int, bool, bool, bool, boo=
l, bool, bool, bool, bool, bool, bool, bool, unsig    #05 pc 0055a17a  /sys=
tem/lib/libart.so (_ZN3art7Runtime4InitEONS_18RuntimeArgumentMapE+11434)</d=
iv><div>=C2=A0 =C2=A0 #06 pc 0055e928  /system/lib/libart.so (art::Runtime:=
:Create(std::__1::vector&lt;std::__1::pair&lt;std::__1::basic_string&lt;cha=
r, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;char&gt;&gt;, =
void const*&gt;, std::__1::allocator&lt;std::__1::pair&lt;std::__1::basic_s=
tring&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;ch=
ar&gt;&gt;, void const*&gt;&gt;&gt; const&amp;, bool)+184)</div></div><div =
class=3D"gmail_extra"><br><div class=3D"gmail_quote">2018-08-01 0:29 GMT+08=
:00 Linus Torvalds <span dir=3D"ltr">&lt;<a href=3D"mailto:torvalds@linux-f=
oundation.org" target=3D"_blank">torvalds@linux-foundation.org</a>&gt;</spa=
n>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Mon, Jul 30, 2018=
 at 11:40 PM Amit Pundir &lt;<a href=3D"mailto:amit.pundir@linaro.org">amit=
.pundir@linaro.org</a>&gt; wrote:<br>
&gt;<br>
&gt; This ashmem change ^^ worked too.<br>
<br>
</span>Ok, let&#39;s go for that one and hope it&#39;s the only one.<br>
<br>
John, can I get a proper commit message and sign-off for that ashmem change=
?<br>
<br>
Kirill - you mentioned that somebody reproduced a problem on x86-64<br>
too. I didn&#39;t see that report. Was that some odd x86 Android setup<br>
with Ashmem too, or is there something else pending?<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0Linus<br>
</font></span></blockquote></div><br></div>

--0000000000007c25b00572538159--
