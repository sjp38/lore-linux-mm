Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A00BF6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 21:50:32 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 184so1126605itm.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 18:50:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f207sor1243360ita.91.2018.03.06.18.50.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 18:50:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ecc197fa-ae01-8be8-55ec-e82eb1050f57@oracle.com>
References: <bug-199037-27@https.bugzilla.kernel.org/> <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <7ffa77c8-8624-9c69-d1f5-058ef22c460c@oracle.com> <ecc197fa-ae01-8be8-55ec-e82eb1050f57@oracle.com>
From: Nic Losby <blurbdust@gmail.com>
Date: Tue, 6 Mar 2018 20:49:50 -0600
Message-ID: <CAD1dD3mgFAv4eOfTdF45G7z052VGdUKVWF_zBa6ABpa3MtC-Fw@mail.gmail.com>
Subject: Re: [Bug 199037] New: Kernel bug at mm/hugetlb.c:741
Content-Type: multipart/alternative; boundary="001a113a79764de21c0566c99f41"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

--001a113a79764de21c0566c99f41
Content-Type: text/plain; charset="UTF-8"

Awesome. Let me know if you need anything else from me. I can keep testing
kernel versions if requested.

Getting a CVE is something that is high on my bucket list. Even though this
is only Denial of Service at best, what are the chances this would be
assigned a CVE?

On Tue, Mar 6, 2018 at 6:31 PM, Mike Kravetz <mike.kravetz@oracle.com>
wrote:

> On 03/06/2018 01:46 PM, Mike Kravetz wrote:
> > On 03/06/2018 01:31 PM, Andrew Morton wrote:
> >>
> >> That's VM_BUG_ON(resv_map->adds_in_progress) in resv_map_release().
> >>
> >> Do you know if earlier kernel versions are affected?
> >>
> >> It looks quite bisectable.  Does the crash happen every time the test
> >> program is run?
> >
> > I'll take a look.  There was a previous bug in this area:
> > ff8c0c53: mm/hugetlb.c: don't call region_abort if region_chg fails
>
> This is similar to the issue addressed in 045c7a3f ("fix offset overflow
> in hugetlbfs mmap").  The problem here is that the pgoff argument passed
> to remap_file_pages() is 0x20000000000000.  In the process of converting
> this to a page offset and putting it in vm_pgoff, and then converting back
> to bytes to compute mapping length we end up with 0.  We ultimately end
> up passing (from,to) page offsets into hugetlbfs where from is greater
> than to. :( This confuses the heck out the the huge page reservation code
> as the 'negative' range looks like an error and we never complete the
> reservation process and leave the 'adds_in_progress'.
>
> This issue has existed for a long time.  The VM_BUG_ON just happens to
> catch the situation which was previously not reported or had some other
> side effect.  Commit 045c7a3f tried to catch these overflow issues when
> converting types, but obviously missed this one.  I can easily add a test
> for this specific value/condition, but want to think about it a little
> more and see if there is a better way to catch all of these.
>
> --
> Mike Kravetz
>

--001a113a79764de21c0566c99f41
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Awesome. Let me know if you need anything else from me. I =
can keep testing kernel versions if requested. <br><br>Getting a CVE is som=
ething that is high on my bucket list. Even though this is only Denial of S=
ervice at best, what are the chances this would be assigned a CVE?</div><di=
v class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Tue, Mar 6, 2018 =
at 6:31 PM, Mike Kravetz <span dir=3D"ltr">&lt;<a href=3D"mailto:mike.krave=
tz@oracle.com" target=3D"_blank">mike.kravetz@oracle.com</a>&gt;</span> wro=
te:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex"><span class=3D"">On 03/06/2018 01:46 =
PM, Mike Kravetz wrote:<br>
&gt; On 03/06/2018 01:31 PM, Andrew Morton wrote:<br>
&gt;&gt;<br>
</span><span class=3D"">&gt;&gt; That&#39;s VM_BUG_ON(resv_map-&gt;adds_in_=
<wbr>progress) in resv_map_release().<br>
&gt;&gt;<br>
&gt;&gt; Do you know if earlier kernel versions are affected?<br>
&gt;&gt;<br>
&gt;&gt; It looks quite bisectable.=C2=A0 Does the crash happen every time =
the test<br>
&gt;&gt; program is run?<br>
&gt;<br>
&gt; I&#39;ll take a look.=C2=A0 There was a previous bug in this area:<br>
&gt; ff8c0c53: mm/hugetlb.c: don&#39;t call region_abort if region_chg fail=
s<br>
<br>
</span>This is similar to the issue addressed in 045c7a3f (&quot;fix offset=
 overflow<br>
in hugetlbfs mmap&quot;).=C2=A0 The problem here is that the pgoff argument=
 passed<br>
to remap_file_pages() is 0x20000000000000.=C2=A0 In the process of converti=
ng<br>
this to a page offset and putting it in vm_pgoff, and then converting back<=
br>
to bytes to compute mapping length we end up with 0.=C2=A0 We ultimately en=
d<br>
up passing (from,to) page offsets into hugetlbfs where from is greater<br>
than to. :( This confuses the heck out the the huge page reservation code<b=
r>
as the &#39;negative&#39; range looks like an error and we never complete t=
he<br>
reservation process and leave the &#39;adds_in_progress&#39;.<br>
<br>
This issue has existed for a long time.=C2=A0 The VM_BUG_ON just happens to=
<br>
catch the situation which was previously not reported or had some other<br>
side effect.=C2=A0 Commit 045c7a3f tried to catch these overflow issues whe=
n<br>
converting types, but obviously missed this one.=C2=A0 I can easily add a t=
est<br>
for this specific value/condition, but want to think about it a little<br>
more and see if there is a better way to catch all of these.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Mike Kravetz<br>
</font></span></blockquote></div><br></div>

--001a113a79764de21c0566c99f41--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
