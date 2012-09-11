Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id AC1016B0062
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 20:27:41 -0400 (EDT)
Received: by obhx4 with SMTP id x4so4907738obh.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 17:27:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
	<20120831134956.fec0f681.akpm@linux-foundation.org>
	<504D467D.2080201@jp.fujitsu.com>
	<504D4A08.7090602@cn.fujitsu.com>
	<20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain>
Date: Tue, 11 Sep 2012 08:27:40 +0800
Message-ID: <CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
From: Jerry <uulinux@gmail.com>
Content-Type: multipart/alternative; boundary=f46d044481d959ad8304c96224d8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

--f46d044481d959ad8304c96224d8
Content-Type: text/plain; charset=ISO-8859-1

Hi Wen,

I have been arranged a job related memory hotplug on ARM architecture.
Maybe I know some new issues about memory hotplug on ARM architecture. I
just enabled it on ARM, and it works well in my Android tablet now.
However, I have not send out my patches. The real reason is that I don't
know how to do it. Maybe I need to read "Documentation/SubmittingPatches".

Hi Andrew,
This is my first time to send you a e-mail. I am so nervous about if I have
some mistakes or not.

Some peoples maybe think memory hotplug need to be supported by special
hardware. Maybe it means memory physical hotplug. Some times, we just need
to use memory logical hotplug, doesn't remove the memory in physical. It is
also usefully for power saving in my platform. Because I doesn't want
the offline memory is in *self-refresh* state.

Any comments are appreciated.

Thanks,
Jerry

2012/9/10 Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

> Hi,
>
> On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:
> > At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
> > > Hi Wen,
> > >
> > > 2012/09/01 5:49, Andrew Morton wrote:
> > >> On Tue, 28 Aug 2012 18:00:07 +0800
> > >> wency@cn.fujitsu.com wrote:
> > >>
> > >>> This patch series aims to support physical memory hot-remove.
> > >>
> > >> I doubt if many people have hardware which permits physical memory
> > >> removal?  How would you suggest that people with regular hardware can
> > >> test these chagnes?
> > >
> > > How do you test the patch? As Andrew says, for hot-removing memory,
> > > we need a particular hardware. I think so too. So many people may want
> > > to know how to test the patch.
> > > If we apply following patch to kvm guest, can we hot-remove memory on
> > > kvm guest?
> > >
> > > http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
> >
> > Yes, if we apply this patchset, we can test hot-remove memory on kvm
> guest.
> > But that patchset doesn't implement _PS3, so there is some restriction.
>
> the following repos contain the patchset above, plus 2 more patches that
> add
> PS3 support to the dimm devices in qemu/seabios:
>
> https://github.com/vliaskov/seabios/commits/memhp-v2
> https://github.com/vliaskov/qemu-kvm/commits/memhp-v2
>
> I have not posted the PS3 patches yet in the qemu list, but will post them
> soon for v3 of the memory hotplug series. If you have issues testing, let
> me
> know.
>
> thanks,
>
> - Vasilis
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
I love linux!!!

--f46d044481d959ad8304c96224d8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Wen,<div><br></div><div>I have been arranged a job related memory hotplu=
g on ARM architecture. Maybe I know some new issues about memory hotplug on=
 ARM architecture. I just enabled it on ARM, and it works well in my Androi=
d tablet now. However, I have not send out my patches. The real reason is t=
hat I don&#39;t know how to do it. Maybe I need to read &quot;Documentation=
/SubmittingPatches&quot;.</div>
<div><br></div><div>Hi Andrew,</div><div>This is my first time to send you =
a e-mail. I am so=A0nervous about if I have some mistakes or not.</div><div=
><br></div><div>Some peoples maybe think memory hotplug need to be supporte=
d by=A0special hardware. Maybe it means memory physical hotplug. Some times=
, we just need to use memory logical hotplug, doesn&#39;t remove the memory=
 in physical. It is also usefully for power saving in my platform. Because =
I doesn&#39;t want the=A0offline=A0memory is in=A0<b>self-refresh</b>=A0sta=
te.</div>
<div><br></div><div>Any=A0comments are=A0appreciated.=A0</div><div><br></di=
v><div>Thanks,</div><div>Jerry</div><div><br><div class=3D"gmail_quote">201=
2/9/10 Vasilis Liaskovitis <span dir=3D"ltr">&lt;<a href=3D"mailto:vasilis.=
liaskovitis@profitbricks.com" target=3D"_blank">vasilis.liaskovitis@profitb=
ricks.com</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hi,<br>
<div class=3D"im"><br>
On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:<br>
&gt; At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:<br>
&gt; &gt; Hi Wen,<br>
&gt; &gt;<br>
&gt; &gt; 2012/09/01 5:49, Andrew Morton wrote:<br>
&gt; &gt;&gt; On Tue, 28 Aug 2012 18:00:07 +0800<br>
&gt; &gt;&gt; <a href=3D"mailto:wency@cn.fujitsu.com">wency@cn.fujitsu.com<=
/a> wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;&gt; This patch series aims to support physical memory hot-rem=
ove.<br>
&gt; &gt;&gt;<br>
</div><div class=3D"im">&gt; &gt;&gt; I doubt if many people have hardware =
which permits physical memory<br>
&gt; &gt;&gt; removal? =A0How would you suggest that people with regular ha=
rdware can<br>
&gt; &gt;&gt; test these chagnes?<br>
&gt; &gt;<br>
&gt; &gt; How do you test the patch? As Andrew says, for hot-removing memor=
y,<br>
&gt; &gt; we need a particular hardware. I think so too. So many people may=
 want<br>
&gt; &gt; to know how to test the patch.<br>
&gt; &gt; If we apply following patch to kvm guest, can we hot-remove memor=
y on<br>
&gt; &gt; kvm guest?<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"http://lists.gnu.org/archive/html/qemu-devel/2012-07/m=
sg01389.html" target=3D"_blank">http://lists.gnu.org/archive/html/qemu-deve=
l/2012-07/msg01389.html</a><br>
&gt;<br>
&gt; Yes, if we apply this patchset, we can test hot-remove memory on kvm g=
uest.<br>
&gt; But that patchset doesn&#39;t implement _PS3, so there is some restric=
tion.<br>
<br>
</div>the following repos contain the patchset above, plus 2 more patches t=
hat add<br>
PS3 support to the dimm devices in qemu/seabios:<br>
<br>
<a href=3D"https://github.com/vliaskov/seabios/commits/memhp-v2" target=3D"=
_blank">https://github.com/vliaskov/seabios/commits/memhp-v2</a><br>
<a href=3D"https://github.com/vliaskov/qemu-kvm/commits/memhp-v2" target=3D=
"_blank">https://github.com/vliaskov/qemu-kvm/commits/memhp-v2</a><br>
<br>
I have not posted the PS3 patches yet in the qemu list, but will post them<=
br>
soon for v3 of the memory hotplug series. If you have issues testing, let m=
e<br>
know.<br>
<br>
thanks,<br>
<br>
- Vasilis<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>=
I love linux!!!<br>
</div>

--f46d044481d959ad8304c96224d8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
