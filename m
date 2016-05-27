Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 190416B0261
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:28:42 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id t106so175439510qgt.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:28:42 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id m2si18190861qkc.42.2016.05.27.09.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 09:28:41 -0700 (PDT)
Received: by mail-qk0-x22d.google.com with SMTP id x7so82977735qkd.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:28:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160525212129.GB15857@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
 <20160525200356.GA15857@node.shutemov.name> <CADf8yx+_EEwys7mip0HspKGMGpacws93afX1zKtHLOmF6-Lj1g@mail.gmail.com>
 <20160525212129.GB15857@node.shutemov.name>
From: neha agarwal <neha.agbk@gmail.com>
Date: Fri, 27 May 2016 12:28:01 -0400
Message-ID: <CADf8yxLK5KE1JBC9m0P+-DgXqt6GPQwRjsTeGkff01-FWQS6MQ@mail.gmail.com>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Content-Type: multipart/alternative; boundary=94eb2c08ad4a4de5e00533d566c1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--94eb2c08ad4a4de5e00533d566c1
Content-Type: text/plain; charset=UTF-8

On Wed, May 25, 2016 at 5:21 PM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Wed, May 25, 2016 at 05:11:03PM -0400, neha agarwal wrote:
> > On Wed, May 25, 2016 at 4:03 PM, Kirill A. Shutemov <
> kirill@shutemov.name>
> > wrote:
> >
> > > On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> > > > Hi All,
> > > >
> > > > I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> > > > Cassandra (NoSQL database). I am seeing significant performance gap
> > > between
> > > > these two implementations (~30%). Hugh's implementation performs
> better
> > > > than Kirill's implementation. I am surprised why I am seeing this
> > > > performance gap. Following is my test setup.
> > >
> > > Thanks for the report. I'll look into it.
> > >
> >
> > Thanks Kirill for looking into it.
> >
> >
> > > > Patchsets
> > > > ========
> > > > - For Hugh's:
> > > > I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> > > > patches) from here: https://lkml.org/lkml/2016/4/5/792 and then
> applied
> > > the
> > > > THP patches posted on April 16 (01 to 29 patches).
> > > >
> > > > - For Kirill's:
> > > > I am using his branch  "git://
> > > > git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8",
> > > which
> > > > is based off of 4.6-rc3, posted on May 12.
> > > >
> > > >
> > > > Khugepaged settings
> > > > ================
> > > > cd /sys/kernel/mm/transparent_hugepage
> > > > echo 10 >khugepaged/alloc_sleep_millisecs
> > > > echo 10 >khugepaged/scan_sleep_millisecs
> > > > echo 511 >khugepaged/max_ptes_none
> > >
> > > Do you make this for both setup?
> > >
> > > It's not really nessesary for Hugh's, but it makes sense to have this
> > > idenatical for testing.
> > >
> >
> > Yeah right, Hugh's will not be impacted by these settings but for
> identical
> > testing I did that.
>
> Could you try to drop this changes and leave khugepaged with defaults.
>

With default khugepaged options also, the performance difference between
the two implementation remains as before.


> One theory is that you just create additional load on the system without
> any gain. As pages wasn't swapped out we have nothing to collapse back,
> but scanning takes CPU time.
>

Since the performance difference is still there with default khugepaged
settings, probably khugepaged is not the culprit here.


>
> Hugh didn't change khugepaged, so it would not need to look into tmpfs
> mapping to check if there's something to collapse...
>
> --
>  Kirill A. Shutemov
>



-- 
Thanks and Regards,
Neha

--94eb2c08ad4a4de5e00533d566c1
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Wed, May 25, 2016 at 5:21 PM, Kirill A. Shutemov <span dir=3D"ltr">&lt;<=
a href=3D"mailto:kirill@shutemov.name" target=3D"_blank">kirill@shutemov.na=
me</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left-width:1px;border-left-style:solid;border-l=
eft-color:rgb(204,204,204);padding-left:1ex"><div><div>On Wed, May 25, 2016=
 at 05:11:03PM -0400, neha agarwal wrote:<br>
&gt; On Wed, May 25, 2016 at 4:03 PM, Kirill A. Shutemov &lt;<a href=3D"mai=
lto:kirill@shutemov.name" target=3D"_blank">kirill@shutemov.name</a>&gt;<br=
>
&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:<br>
&gt; &gt; &gt; Hi All,<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I have been testing Hugh&#39;s and Kirill&#39;s huge tmpfs p=
atch sets with<br>
&gt; &gt; &gt; Cassandra (NoSQL database). I am seeing significant performa=
nce gap<br>
&gt; &gt; between<br>
&gt; &gt; &gt; these two implementations (~30%). Hugh&#39;s implementation =
performs better<br>
&gt; &gt; &gt; than Kirill&#39;s implementation. I am surprised why I am se=
eing this<br>
&gt; &gt; &gt; performance gap. Following is my test setup.<br>
&gt; &gt;<br>
&gt; &gt; Thanks for the report. I&#39;ll look into it.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Thanks Kirill for looking into it.<br>
&gt;<br>
&gt;<br>
&gt; &gt; &gt; Patchsets<br>
&gt; &gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; &gt; - For Hugh&#39;s:<br>
&gt; &gt; &gt; I checked out 4.6-rc3, applied Hugh&#39;s preliminary patche=
s (01 to 10<br>
&gt; &gt; &gt; patches) from here: <a href=3D"https://lkml.org/lkml/2016/4/=
5/792" rel=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2016/4/5/=
792</a> and then applied<br>
&gt; &gt; the<br>
&gt; &gt; &gt; THP patches posted on April 16 (01 to 29 patches).<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; - For Kirill&#39;s:<br>
&gt; &gt; &gt; I am using his branch=C2=A0 &quot;git://<br>
&gt; &gt; &gt; <a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/ka=
s/linux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/li=
nux/kernel/git/kas/linux.git</a> hugetmpfs/v8&quot;,<br>
&gt; &gt; which<br>
&gt; &gt; &gt; is based off of 4.6-rc3, posted on May 12.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Khugepaged settings<br>
&gt; &gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; &gt; cd /sys/kernel/mm/transparent_hugepage<br>
&gt; &gt; &gt; echo 10 &gt;khugepaged/alloc_sleep_millisecs<br>
&gt; &gt; &gt; echo 10 &gt;khugepaged/scan_sleep_millisecs<br>
&gt; &gt; &gt; echo 511 &gt;khugepaged/max_ptes_none<br>
&gt; &gt;<br>
&gt; &gt; Do you make this for both setup?<br>
&gt; &gt;<br>
&gt; &gt; It&#39;s not really nessesary for Hugh&#39;s, but it makes sense =
to have this<br>
&gt; &gt; idenatical for testing.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Yeah right, Hugh&#39;s will not be impacted by these settings but for =
identical<br>
&gt; testing I did that.<br>
<br>
</div></div>Could you try to drop this changes and leave khugepaged with de=
faults.<br></blockquote><div>=C2=A0</div><div>With default khugepaged optio=
ns also, the performance difference between the two implementation remains =
as before.=C2=A0</div><div><br></div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-style:solid=
;border-left-color:rgb(204,204,204);padding-left:1ex">
<br>
One theory is that you just create additional load on the system without<br=
>
any gain. As pages wasn&#39;t swapped out we have nothing to collapse back,=
<br>
but scanning takes CPU time.<br></blockquote><div><br></div><div><span styl=
e=3D"color:rgb(38,50,56);font-size:13px;line-height:16px">Since the perform=
ance difference is still there with default khugepaged settings, probably k=
hugepaged is not the culprit here.</span><br></div><div>=C2=A0<br></div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-lef=
t-width:1px;border-left-style:solid;border-left-color:rgb(204,204,204);padd=
ing-left:1ex">
<br>
Hugh didn&#39;t change khugepaged, so it would not need to look into tmpfs<=
br>
mapping to check if there&#39;s something to collapse...<br>
<span><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div><div dir=3D"ltr">Thanks and Regards,<div>Neha</div></div></div>
</div></div>

--94eb2c08ad4a4de5e00533d566c1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
