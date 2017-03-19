Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 797DF6B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 04:27:00 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g138so87429591itb.4
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 01:27:00 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id c195si7235749itb.108.2017.03.19.01.26.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 01:26:59 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id y18so4914652itc.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 01:26:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <877f3lfzdo.fsf@skywalker.in.ibm.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-27-kirill.shutemov@linux.intel.com> <87a88jg571.fsf@skywalker.in.ibm.com>
 <20170317175714.3bvpdylaaudf4ig2@node.shutemov.name> <877f3lfzdo.fsf@skywalker.in.ibm.com>
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Sun, 19 Mar 2017 11:26:58 +0300
Message-ID: <CAFZ8GQx2JmEECQHEsKOymP8nDv9YHfLgcK80R75gM+r-1q-owQ@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above 47-bits
Content-Type: multipart/alternative; boundary=001a11449ffca93443054b112ced
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

--001a11449ffca93443054b112ced
Content-Type: text/plain; charset=UTF-8

On Mar 19, 2017 09:25, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
wrote:

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Fri, Mar 17, 2017 at 11:23:54PM +0530, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>>
>> > On x86, 5-level paging enables 56-bit userspace virtual address space.
>> > Not all user space is ready to handle wide addresses. It's known that
>> > at least some JIT compilers use higher bits in pointers to encode their
>> > information. It collides with valid pointers with 5-level paging and
>> > leads to crashes.
>> >
>> > To mitigate this, we are not going to allocate virtual address space
>> > above 47-bit by default.
>> >
>> > But userspace can ask for allocation from full address space by
>> > specifying hint address (with or without MAP_FIXED) above 47-bits.
>> >
>> > If hint address set above 47-bit, but MAP_FIXED is not specified, we
try
>> > to look for unmapped area by specified address. If it's already
>> > occupied, we look for unmapped area in *full* address space, rather
than
>> > from 47-bit window.
>> >
>> > This approach helps to easily make application's memory allocator aware
>> > about large address space without manually tracking allocated virtual
>> > address space.
>> >
>>
>> So if I have done a successful mmap which returned > 128TB what should a
>> following mmap(0,...) return ? Should that now search the *full* address
>> space or below 128TB ?
>
> No, I don't think so. And this implementation doesn't do this.
>
> It's safer this way: if an library can't handle high addresses, it's
> better not to switch it automagically to full address space if other part
> of the process requested high address.
>

What is the epectation when the hint addr is below 128TB but addr + len >
128TB ? Should such mmap request fail ?


Yes, I believe so.

--001a11449ffca93443054b112ced
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Mar 19, 2017 09:25, &quot;Aneesh Kumar K.V&quot; &lt;<a href=
=3D"mailto:aneesh.kumar@linux.vnet.ibm.com">aneesh.kumar@linux.vnet.ibm.com=
</a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div cla=
ss=3D"elided-text">&quot;Kirill A. Shutemov&quot; &lt;<a href=3D"mailto:kir=
ill@shutemov.name">kirill@shutemov.name</a>&gt; writes:<br>
<br>
&gt; On Fri, Mar 17, 2017 at 11:23:54PM +0530, Aneesh Kumar K.V wrote:<br>
&gt;&gt; &quot;Kirill A. Shutemov&quot; &lt;<a href=3D"mailto:kirill.shutem=
ov@linux.intel.com">kirill.shutemov@linux.intel.<wbr>com</a>&gt; writes:<br=
>
&gt;&gt;<br>
&gt;&gt; &gt; On x86, 5-level paging enables 56-bit userspace virtual addre=
ss space.<br>
&gt;&gt; &gt; Not all user space is ready to handle wide addresses. It&#39;=
s known that<br>
&gt;&gt; &gt; at least some JIT compilers use higher bits in pointers to en=
code their<br>
&gt;&gt; &gt; information. It collides with valid pointers with 5-level pag=
ing and<br>
&gt;&gt; &gt; leads to crashes.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; To mitigate this, we are not going to allocate virtual addres=
s space<br>
&gt;&gt; &gt; above 47-bit by default.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; But userspace can ask for allocation from full address space =
by<br>
&gt;&gt; &gt; specifying hint address (with or without MAP_FIXED) above 47-=
bits.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; If hint address set above 47-bit, but MAP_FIXED is not specif=
ied, we try<br>
&gt;&gt; &gt; to look for unmapped area by specified address. If it&#39;s a=
lready<br>
&gt;&gt; &gt; occupied, we look for unmapped area in *full* address space, =
rather than<br>
&gt;&gt; &gt; from 47-bit window.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; This approach helps to easily make application&#39;s memory a=
llocator aware<br>
&gt;&gt; &gt; about large address space without manually tracking allocated=
 virtual<br>
&gt;&gt; &gt; address space.<br>
&gt;&gt; &gt;<br>
&gt;&gt;<br>
&gt;&gt; So if I have done a successful mmap which returned &gt; 128TB what=
 should a<br>
&gt;&gt; following mmap(0,...) return ? Should that now search the *full* a=
ddress<br>
&gt;&gt; space or below 128TB ?<br>
&gt;<br>
&gt; No, I don&#39;t think so. And this implementation doesn&#39;t do this.=
<br>
&gt;<br>
&gt; It&#39;s safer this way: if an library can&#39;t handle high addresses=
, it&#39;s<br>
&gt; better not to switch it automagically to full address space if other p=
art<br>
&gt; of the process requested high address.<br>
&gt;<br>
<br>
</div>What is the epectation when the hint addr is below 128TB but addr + l=
en &gt;<br>
128TB ? Should such mmap request fail ?<br>
<div class=3D"elided-text"></div></blockquote></div></div></div><div dir=3D=
"auto"><br></div><div dir=3D"auto">Yes, I believe so.</div><div dir=3D"auto=
"><br></div><div dir=3D"auto"><br></div></div>

--001a11449ffca93443054b112ced--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
