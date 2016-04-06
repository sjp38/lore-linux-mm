Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 78C816B026F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 02:56:15 -0400 (EDT)
Received: by mail-vk0-f41.google.com with SMTP id e6so46990641vkh.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:56:15 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id 93si315902uaq.107.2016.04.05.23.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 23:56:14 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id k1so47035334vkb.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:56:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5704B0E4.9060300@redhat.com>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
	<alpine.LSU.2.11.1604051439340.5965@eggly.anvils>
	<57044C3A.7060109@redhat.com>
	<alpine.LSU.2.11.1604051756020.7348@eggly.anvils>
	<5704B0E4.9060300@redhat.com>
Date: Tue, 5 Apr 2016 23:56:14 -0700
Message-ID: <CAJu=L5_5PzujK5UAqhorufjuSEuHcHUrfi0NQNmiLJefE59oQg@mail.gmail.com>
Subject: Re: [PATCH 17/31] kvm: teach kvm to map page teams as huge pages.
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=001a114314dc2f4f41052fcb75d3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org

--001a114314dc2f4f41052fcb75d3
Content-Type: text/plain; charset=UTF-8

The rule is: this is_huge_tmpfs() block of code could be used anywhere a
lock serializing against mmu notifiers is held.

It's arguable (mildly?) how broad of a clientele for huge tmpfs that is,
outside kvm.

Andres

On Tue, Apr 5, 2016 at 11:47 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:

>
>
> On 06/04/2016 03:12, Hugh Dickins wrote:
> > Hah, you've lighted on precisely a line of code where I changed around
> > what Andres had - I thought it nicer to pass down vcpu, because that
> > matched the function above, and in many cases vcpu is not dereferenced
> > here at all.  So, definitely blame me not Andres for that interface.
> >
>
> Oh, actually I'm fine with the interface if it's in arch/x86/kvm.  I'm
> just pointing out that---putting aside the locking question---it's a
> pretty generic thing that doesn't really need access to KVM data
> structures.
>
> Paolo
>



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--001a114314dc2f4f41052fcb75d3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">The rule is: this is_huge_tmpfs() block of code could be u=
sed anywhere a lock serializing against mmu notifiers is held.<div><br></di=
v><div>It&#39;s arguable (mildly?) how broad of a clientele for huge tmpfs =
that is, outside kvm.</div><div><br></div><div>Andres</div></div><div class=
=3D"gmail_extra"><br><div class=3D"gmail_quote">On Tue, Apr 5, 2016 at 11:4=
7 PM, Paolo Bonzini <span dir=3D"ltr">&lt;<a href=3D"mailto:pbonzini@redhat=
.com" target=3D"_blank">pbonzini@redhat.com</a>&gt;</span> wrote:<br><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex"><span class=3D""><br>
<br>
On 06/04/2016 03:12, Hugh Dickins wrote:<br>
&gt; Hah, you&#39;ve lighted on precisely a line of code where I changed ar=
ound<br>
&gt; what Andres had - I thought it nicer to pass down vcpu, because that<b=
r>
&gt; matched the function above, and in many cases vcpu is not dereferenced=
<br>
&gt; here at all.=C2=A0 So, definitely blame me not Andres for that interfa=
ce.<br>
&gt;<br>
<br>
</span>Oh, actually I&#39;m fine with the interface if it&#39;s in arch/x86=
/kvm.=C2=A0 I&#39;m<br>
just pointing out that---putting aside the locking question---it&#39;s a<br=
>
pretty generic thing that doesn&#39;t really need access to KVM data struct=
ures.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Paolo<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"gmail_signature"><div dir=3D"ltr"><span style=3D"color:rgb(=
85,85,85);font-family:sans-serif;font-size:small;line-height:19.5px;border-=
width:2px 0px 0px;border-style:solid;border-color:rgb(213,15,37);padding-to=
p:2px;margin-top:2px">Andres Lagar-Cavilla=C2=A0|</span><span style=3D"colo=
r:rgb(85,85,85);font-family:sans-serif;font-size:small;line-height:19.5px;b=
order-width:2px 0px 0px;border-style:solid;border-color:rgb(51,105,232);pad=
ding-top:2px;margin-top:2px">=C2=A0Google Kernel Team |</span><span style=
=3D"color:rgb(85,85,85);font-family:sans-serif;font-size:small;line-height:=
19.5px;border-width:2px 0px 0px;border-style:solid;border-color:rgb(0,153,5=
7);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:andreslc@google.=
com" target=3D"_blank">andreslc@google.com</a>=C2=A0</span><br></div></div>
</div>

--001a114314dc2f4f41052fcb75d3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
