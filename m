Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9CC6B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 19:07:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id c5-v6so12522281ioi.13
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:07:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p58-v6sor6315920jak.36.2018.07.31.16.07.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 16:07:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com> <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
From: youling 257 <youling257@gmail.com>
Date: Wed, 1 Aug 2018 07:07:31 +0800
Message-ID: <CAOzgRdYauteaS7hsPGOCt7a3jgciGk43BOjWuk9yQNt3xaqeyw@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: multipart/alternative; boundary="000000000000b7ee31057253a51b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

--000000000000b7ee31057253a51b
Content-Type: text/plain; charset="UTF-8"

my x86 report

isPrevious: true
Build:
Android-x86/android_x86/x86:8.1.0/OPM6.171019.030.B1/cwhuang0618:userdebug/test-keys
Hardware: unknown
Revision: 0
Bootloader: unknown
Radio: unknown
Kernel: Linux version 4.18.0-rc7-android-x86_64+ (root@localhost) (gcc
version 8.2.0 (Ubuntu 8.2.0-1ubuntu2)) #1 SMP PREEMPT Mon Jul 30 12:26:29
CST 2018

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
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
    #07 pc 003a1117 /system/lib/libart.so (JNI_CreateJavaVM+647)
    #08 pc 000044ae /system/lib/libnativehelper.so (JNI_CreateJavaVM+46)
    #09 pc 00078d1d /system/lib/libandroid_runtime.so
(android::AndroidRuntime::startVm(_JavaVM**, _JNIEnv**, bool)+7581)
    #10 pc 000791fb /system/lib/libandroid_runtime.so
(android::AndroidRuntime::start(char const*,
android::Vector<android::String8> const&, bool)+395)
    #11 pc 00003119 /system/bin/app_process32 (main+1689)
    #12 pc 000b6a34 /system/lib/libc.so (__libc_init+100)
    #13 pc 000029dd /system/bin/app_process32 (_start_main+80)
    #14 pc 000029e8 /system/bin/app_process32 (_start+10)
    #15 pc 00000004 <unknown>
    #16 pc 00020b69 [stack:ffc31000]

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

--000000000000b7ee31057253a51b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">my x86 report<div><br></div><div>isPrevious: true</div><di=
v>Build: Android-x86/android_x86/x86:8.1.0/OPM6.171019.030.B1/cwhuang0618:u=
serdebug/test-keys</div><div>Hardware: unknown</div><div>Revision: 0</div><=
div>Bootloader: unknown</div><div>Radio: unknown</div><div>Kernel: Linux ve=
rsion 4.18.0-rc7-android-x86_64+ (root@localhost) (gcc version 8.2.0 (Ubunt=
u 8.2.0-1ubuntu2)) #1 SMP PREEMPT Mon Jul 30 12:26:29 CST 2018</div><div><b=
r></div><div>*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** **=
*</div><div>Build fingerprint: &#39;Android-x86/android_x86/x86:8.1.0/OPM6.=
171019.030.B1/cwhuang0618:userdebug/test-keys&#39;</div><div>Revision: &#39=
;0&#39;</div><div>ABI: &#39;x86&#39;</div><div>pid: 2899, tid: 2899, name: =
zygote  &gt;&gt;&gt; zygote &lt;&lt;&lt;</div><div>signal 7 (SIGBUS), code =
2 (BUS_ADRERR), fault addr 0xec00008</div><div>=C2=A0 =C2=A0 eax 00000000  =
ebx f0274a40  ecx 000001e0  edx 0ec00008</div><div>=C2=A0 =C2=A0 esi 000000=
00  edi 0ec00000</div><div>=C2=A0 =C2=A0 xcs 00000023  xds 0000002b  xes 00=
00002b  xfs 00000003  xss 0000002b</div><div>=C2=A0 =C2=A0 eip f24a4996  eb=
p ffc4eaa8  esp ffc4ea68  flags 00010202</div><div><br></div><div>backtrace=
:</div><div>=C2=A0 =C2=A0 #00 pc 0001a996  /system/lib/libc.so (memset+150)=
</div><div>=C2=A0 =C2=A0 #01 pc 0022b2be  /system/lib/libart.so (create_msp=
ace_with_base+222)</div><div>=C2=A0 =C2=A0 #02 pc 002b2a05  /system/lib/lib=
art.so (art::gc::space::DlMallocSpace::CreateMspace(void*, unsigned int, un=
signed int)+69)</div><div>=C2=A0 =C2=A0 #03 pc 002b2637  /system/lib/libart=
.so (art::gc::space::DlMallocSpace::CreateFromMemMap(art::MemMap*, std::__1=
::basic_string&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::alloca=
tor&lt;char&gt;&gt; const&amp;, unsigned int, unsigned int, unsigned int, u=
nsigned int, bool)+55)</div><div>=C2=A0 =C2=A0 #04 pc 0027f6af  /system/lib=
/libart.so (art::gc::Heap::Heap(unsigned int, unsigned int, unsigned int, u=
nsigned int, double, double, unsigned int, unsigned int, std::__1::basic_st=
ring&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;cha=
r&gt;&gt; const&amp;, art::InstructionSet, art::gc::CollectorType, art::gc:=
:CollectorType, art::gc::space::LargeObjectSpaceType, unsigned int, unsigne=
d int, unsigned int, bool, unsigned int, unsigned int, bool, bool, bool, bo=
ol, bool, bool, bool, bool, bool, bool, bool, unsig    #05 pc 0055a17a  /sy=
stem/lib/libart.so (_ZN3art7Runtime4InitEONS_18RuntimeArgumentMapE+11434)</=
div><div>=C2=A0 =C2=A0 #06 pc 0055e928  /system/lib/libart.so (art::Runtime=
::Create(std::__1::vector&lt;std::__1::pair&lt;std::__1::basic_string&lt;ch=
ar, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;char&gt;&gt;,=
 void const*&gt;, std::__1::allocator&lt;std::__1::pair&lt;std::__1::basic_=
string&lt;char, std::__1::char_traits&lt;char&gt;, std::__1::allocator&lt;c=
har&gt;&gt;, void const*&gt;&gt;&gt; const&amp;, bool)+184)</div><div>=C2=
=A0 =C2=A0 #07 pc 003a1117  /system/lib/libart.so (JNI_CreateJavaVM+647)</d=
iv><div>=C2=A0 =C2=A0 #08 pc 000044ae  /system/lib/libnativehelper.so (JNI_=
CreateJavaVM+46)</div><div>=C2=A0 =C2=A0 #09 pc 00078d1d  /system/lib/liban=
droid_runtime.so (android::AndroidRuntime::startVm(_JavaVM**, _JNIEnv**, bo=
ol)+7581)</div><div>=C2=A0 =C2=A0 #10 pc 000791fb  /system/lib/libandroid_r=
untime.so (android::AndroidRuntime::start(char const*, android::Vector&lt;a=
ndroid::String8&gt; const&amp;, bool)+395)</div><div>=C2=A0 =C2=A0 #11 pc 0=
0003119  /system/bin/app_process32 (main+1689)</div><div>=C2=A0 =C2=A0 #12 =
pc 000b6a34  /system/lib/libc.so (__libc_init+100)</div><div>=C2=A0 =C2=A0 =
#13 pc 000029dd  /system/bin/app_process32 (_start_main+80)</div><div>=C2=
=A0 =C2=A0 #14 pc 000029e8  /system/bin/app_process32 (_start+10)</div><div=
>=C2=A0 =C2=A0 #15 pc 00000004  &lt;unknown&gt;</div><div>=C2=A0 =C2=A0 #16=
 pc 00020b69  [stack:ffc31000]</div></div><div class=3D"gmail_extra"><br><d=
iv class=3D"gmail_quote">2018-08-01 0:29 GMT+08:00 Linus Torvalds <span dir=
=3D"ltr">&lt;<a href=3D"mailto:torvalds@linux-foundation.org" target=3D"_bl=
ank">torvalds@linux-foundation.org</a>&gt;</span>:<br><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex"><span class=3D"">On Mon, Jul 30, 2018 at 11:40 PM Amit Pundir &lt=
;<a href=3D"mailto:amit.pundir@linaro.org">amit.pundir@linaro.org</a>&gt; w=
rote:<br>
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

--000000000000b7ee31057253a51b--
