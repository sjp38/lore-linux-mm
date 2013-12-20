Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id D98056B0037
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 03:25:25 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id n7so1947532qcx.33
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 00:25:25 -0800 (PST)
Received: from mail-vb0-x233.google.com (mail-vb0-x233.google.com [2607:f8b0:400c:c02::233])
        by mx.google.com with ESMTPS id nh12si5193560qeb.80.2013.12.20.00.25.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 00:25:24 -0800 (PST)
Received: by mail-vb0-f51.google.com with SMTP id 11so1205934vbe.24
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 00:25:24 -0800 (PST)
MIME-Version: 1.0
Reply-To: matvejchikov@gmail.com
In-Reply-To: <20131220024126.GA1852@hp530>
References: <CAKh5naYHUUUPnSv4skmX=+88AB-L=M4ruQti5cX=1BRxZY2JRg@mail.gmail.com>
 <20131220024126.GA1852@hp530>
From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Fri, 20 Dec 2013 12:25:04 +0400
Message-ID: <CAKh5naY5Y7Vo7jq7FrLoEb3792w0Kz1A=0+aS-oKtHj_omAKXg@mail.gmail.com>
Subject: Re: A question aboout virtual mapping of kernel and module pages
Content-Type: multipart/alternative; boundary=047d7b3435c00d495c04edf3056b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Cc: linux-mm@kvack.org

--047d7b3435c00d495c04edf3056b
Content-Type: text/plain; charset=ISO-8859-1

Hi Vladimir,

Thanks for the suggestion, but the problem was not in mapping itself. I've
been mistaken
about
it
as
the problem I've had was related to bug in my code. Thanks for the idea to
check if I-D cache aliasing happens. It turns me to the
right
direction :)

2013/12/20 Vladimir Murzin <murzin.v@gmail.com>

> Hi Ilya!
>
> On Fri, Dec 20, 2013 at 12:25:13AM +0400, Matvejchikov Ilya wrote:
> > I'm using VMAP function to create memory writable mapping as it
suggested
> > in ksplice project. Here is the implementation of map_writable function:
> > ...
> >
> > This function works well when I used it to map kernel's text addresses.
All
> > fine and I can rewrite read-only data well via the mapping.
> >
> > Now, I need to modify kernel module's text. Given the symbol address
inside
> > the module, I use the same method. The mapping I've got seems to be
valid.
> > But all my changes visible only in that mapping and not in the module!
> >
> > I suppose that in case of module mapping I get something like
copy-on-write
> > but I can't prove it.
> >
>
> Looks like I-D cache aliasing... Have you flushed cashes after your
> modifications were done?
>
> Vladimir
>
> > Can anyone explain me what's happend and why I can use it for mapping
> > kernel and can't for modules?
> >
> >
http://stackoverflow.com/questions/20658357/virtual-mapping-of-kernel-and-module-pages

--047d7b3435c00d495c04edf3056b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:verdana,=
sans-serif;color:rgb(0,0,255);display:inline"></div>Hi Vladimir,<br><br>Tha=
nks for the suggestion, but the problem was not in mapping itself. I&#39;ve=
 been mistaken<div class=3D"gmail_default" style=3D"font-family:verdana,san=
s-serif;color:rgb(0,0,255);display:inline">

 </div>about<div class=3D"gmail_default" style=3D"font-family:verdana,sans-=
serif;color:rgb(0,0,255);display:inline"> </div>it<div class=3D"gmail_defau=
lt" style=3D"font-family:verdana,sans-serif;color:rgb(0,0,255);display:inli=
ne">

 </div>as<div class=3D"gmail_default" style=3D"font-family:verdana,sans-ser=
if;color:rgb(0,0,255);display:inline"> </div>the problem I&#39;ve had was r=
elated to bug in my code. Thanks for the idea to<div class=3D"gmail_default=
" style=3D"font-family:verdana,sans-serif;color:rgb(0,0,255);display:inline=
">

 </div>check if I-D cache aliasing happens. It turns me to the<div class=3D=
"gmail_default" style=3D"font-family:verdana,sans-serif;color:rgb(0,0,255);=
display:inline"> </div>right<div class=3D"gmail_default" style=3D"font-fami=
ly:verdana,sans-serif;color:rgb(0,0,255);display:inline">

 </div>direction :)<br><br>2013/12/20 Vladimir Murzin &lt;<a href=3D"mailto=
:murzin.v@gmail.com" target=3D"_blank">murzin.v@gmail.com</a>&gt;<br>
<br>&gt; Hi Ilya!<br>&gt;<br>&gt; On Fri, Dec 20, 2013 at 12:25:13AM +0400,=
 Matvejchikov Ilya wrote:<br>&gt; &gt; I&#39;m using VMAP function to creat=
e memory writable mapping as it suggested<br>&gt; &gt; in ksplice project. =
Here is the implementation of map_writable function:<br>


&gt; &gt; ...<br>&gt; &gt;<br>&gt; &gt; This function works well when I use=
d it to map kernel&#39;s text addresses. All<br>&gt; &gt; fine and I can re=
write read-only data well via the mapping.<br>&gt; &gt;<br>&gt; &gt; Now, I=
 need to modify kernel module&#39;s text. Given the symbol address inside<b=
r>


&gt; &gt; the module, I use the same method. The mapping I&#39;ve got seems=
 to be valid.<br>&gt; &gt; But all my changes visible only in that mapping =
and not in the module!<br>&gt; &gt;<br>&gt; &gt; I suppose that in case of =
module mapping I get something like copy-on-write<br>


&gt; &gt; but I can&#39;t prove it.<br>&gt; &gt;<br>&gt;<br>&gt; Looks like=
 I-D cache aliasing... Have you flushed cashes after your<br>&gt; modificat=
ions were done?<br>&gt;<br>&gt; Vladimir<br>&gt;<br>&gt; &gt; Can anyone ex=
plain me what&#39;s happend and why I can use it for mapping<br>


&gt; &gt; kernel and can&#39;t for modules?<br>&gt; &gt;<br>&gt; &gt; <a hr=
ef=3D"http://stackoverflow.com/questions/20658357/virtual-mapping-of-kernel=
-and-module-pages" target=3D"_blank">http://stackoverflow.com/questions/206=
58357/virtual-mapping-of-kernel-and-module-pages</a><br>


</div>

--047d7b3435c00d495c04edf3056b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
