Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 5D8856B009C
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:18:25 -0400 (EDT)
Received: by obhx4 with SMTP id x4so200573obh.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 22:18:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120911012345.GD14205@bbox>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
	<20120831134956.fec0f681.akpm@linux-foundation.org>
	<504D467D.2080201@jp.fujitsu.com>
	<504D4A08.7090602@cn.fujitsu.com>
	<20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain>
	<CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>
	<20120911012345.GD14205@bbox>
Date: Tue, 11 Sep 2012 13:18:24 +0800
Message-ID: <CAAV+Mu4hb0qbW2Ry6w5FAGUM06puDH0v_H-jr584-G9CzJqSGw@mail.gmail.com>
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
From: Jerry <uulinux@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8fb201e2126a2004c9663479
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Wen Congyang <wency@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, kosaki.motohiro@jp.fujitsu.com

--e89a8fb201e2126a2004c9663479
Content-Type: text/plain; charset=ISO-8859-1

Hi Kim,

Thank you for your kindness. Let me clarify this:

On ARM architecture, there are 32 bits physical addresses space. However,
the addresses space is divided into 8 banks normally. Each bank
disabled/enabled by a chip selector signal. In my platform, bank0 connects
a DDR chip, and bank1 also connects another DDR chip. And each DDR chip
whose capability is 512MB is integrated into the main board. So, it could
not be removed by hand. We can disable/enable each bank by peripheral
device controller registers.

When system enter suspend state, if all the pages allocated could be
migrated to one bank, there are no valid data in the another bank. In this
time, I could disable the free bank. It isn't necessary to provided power
to this chip in the suspend state. When system resume, I just need to
enable it again.

Hi Wen,

I am sorry for that I doesn't know the "_PSx support" means. Maybe I
needn't it.

Thanks,
Jerry

2012/9/11 Minchan Kim <minchan@kernel.org>

> Hi Jerry,
>
> On Tue, Sep 11, 2012 at 08:27:40AM +0800, Jerry wrote:
> > Hi Wen,
> >
> > I have been arranged a job related memory hotplug on ARM architecture.
> > Maybe I know some new issues about memory hotplug on ARM architecture. I
> > just enabled it on ARM, and it works well in my Android tablet now.
> > However, I have not send out my patches. The real reason is that I don't
> > know how to do it. Maybe I need to read
> "Documentation/SubmittingPatches".
> >
> > Hi Andrew,
> > This is my first time to send you a e-mail. I am so nervous about if I
> have
> > some mistakes or not.
>
> Don't be afraid.
> If you might make a mistake, it's very natural to newbie.
> I am sure anyone doesn't blame you. :)
> If you have a good patch, please send out.
>
> >
> > Some peoples maybe think memory hotplug need to be supported by special
> > hardware. Maybe it means memory physical hotplug. Some times, we just
> need
> > to use memory logical hotplug, doesn't remove the memory in physical. It
> is
> > also usefully for power saving in my platform. Because I doesn't want
> > the offline memory is in *self-refresh* state.
>
> Just out of curiosity.
> What's the your scenario and gain?
> AFAIK, there were some effort about it in embedded side but gain isn't
> rather big
> IIRC.
>
> >
> > Any comments are appreciated.
> >
> > Thanks,
> > Jerry
> >
> > 2012/9/10 Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
> >
> > > Hi,
> > >
> > > On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:
> > > > At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
> > > > > Hi Wen,
> > > > >
> > > > > 2012/09/01 5:49, Andrew Morton wrote:
> > > > >> On Tue, 28 Aug 2012 18:00:07 +0800
> > > > >> wency@cn.fujitsu.com wrote:
> > > > >>
> > > > >>> This patch series aims to support physical memory hot-remove.
> > > > >>
> > > > >> I doubt if many people have hardware which permits physical memory
> > > > >> removal?  How would you suggest that people with regular hardware
> can
> > > > >> test these chagnes?
> > > > >
> > > > > How do you test the patch? As Andrew says, for hot-removing memory,
> > > > > we need a particular hardware. I think so too. So many people may
> want
> > > > > to know how to test the patch.
> > > > > If we apply following patch to kvm guest, can we hot-remove memory
> on
> > > > > kvm guest?
> > > > >
> > > > > http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
> > > >
> > > > Yes, if we apply this patchset, we can test hot-remove memory on kvm
> > > guest.
> > > > But that patchset doesn't implement _PS3, so there is some
> restriction.
> > >
> > > the following repos contain the patchset above, plus 2 more patches
> that
> > > add
> > > PS3 support to the dimm devices in qemu/seabios:
> > >
> > > https://github.com/vliaskov/seabios/commits/memhp-v2
> > > https://github.com/vliaskov/qemu-kvm/commits/memhp-v2
> > >
> > > I have not posted the PS3 patches yet in the qemu list, but will post
> them
> > > soon for v3 of the memory hotplug series. If you have issues testing,
> let
> > > me
> > > know.
> > >
> > > thanks,
> > >
> > > - Vasilis
> > >
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > >
> >
> >
> >
> > --
> > I love linux!!!
>
> --
> Kind regards,
> Minchan Kim
>



-- 
I love linux!!!

--e89a8fb201e2126a2004c9663479
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Kim,<div><br></div><div><div>Thank you for your kindness. Let me clarify=
 this:</div><div><br></div><div>On ARM architecture, there are 32 bits phys=
ical addresses space. However, the addresses space is divided into 8 banks =
normally. Each bank disabled/enabled by a chip selector signal. In my platf=
orm, bank0 connects a DDR chip, and bank1 also connects another DDR chip. A=
nd each DDR chip whose capability is 512MB is integrated into the main boar=
d. So, it could not be removed by hand. We can disable/enable each bank by =
peripheral device controller registers.</div>
<div><br></div><div>When system enter suspend state, if all the pages alloc=
ated could be migrated to one bank, there are no valid data in the another =
bank. In this time, I could disable the free bank. It isn&#39;t necessary t=
o provided power to this chip in the suspend state. When system resume, I j=
ust need to enable it again.</div>
</div><div><br></div><div>Hi Wen,</div><div><br></div><div>I am sorry for t=
hat I doesn&#39;t know the &quot;<span style=3D"background-color:rgb(255,25=
5,255);color:rgb(34,34,34);font-family:arial,sans-serif;font-size:14px">_PS=
x support</span>&quot; means. Maybe I needn&#39;t it.</div>
<div><br></div><div>Thanks,</div><div>Jerry=A0<br><br><div class=3D"gmail_q=
uote">2012/9/11 Minchan Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan=
@kernel.org" target=3D"_blank">minchan@kernel.org</a>&gt;</span><br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">
Hi Jerry,<br>
<div class=3D"im"><br>
On Tue, Sep 11, 2012 at 08:27:40AM +0800, Jerry wrote:<br>
&gt; Hi Wen,<br>
&gt;<br>
&gt; I have been arranged a job related memory hotplug on ARM architecture.=
<br>
&gt; Maybe I know some new issues about memory hotplug on ARM architecture.=
 I<br>
&gt; just enabled it on ARM, and it works well in my Android tablet now.<br=
>
&gt; However, I have not send out my patches. The real reason is that I don=
&#39;t<br>
&gt; know how to do it. Maybe I need to read &quot;Documentation/Submitting=
Patches&quot;.<br>
&gt;<br>
&gt; Hi Andrew,<br>
&gt; This is my first time to send you a e-mail. I am so nervous about if I=
 have<br>
&gt; some mistakes or not.<br>
<br>
</div>Don&#39;t be afraid.<br>
If you might make a mistake, it&#39;s very natural to newbie.<br>
I am sure anyone doesn&#39;t blame you. :)<br>
If you have a good patch, please send out.<br>
<div class=3D"im"><br>
&gt;<br>
&gt; Some peoples maybe think memory hotplug need to be supported by specia=
l<br>
&gt; hardware. Maybe it means memory physical hotplug. Some times, we just =
need<br>
&gt; to use memory logical hotplug, doesn&#39;t remove the memory in physic=
al. It is<br>
&gt; also usefully for power saving in my platform. Because I doesn&#39;t w=
ant<br>
</div>&gt; the offline memory is in *self-refresh* state.<br>
<br>
Just out of curiosity.<br>
What&#39;s the your scenario and gain?<br>
AFAIK, there were some effort about it in embedded side but gain isn&#39;t =
rather big<br>
IIRC.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt;<br>
&gt; Any comments are appreciated.<br>
&gt;<br>
&gt; Thanks,<br>
&gt; Jerry<br>
&gt;<br>
&gt; 2012/9/10 Vasilis Liaskovitis &lt;<a href=3D"mailto:vasilis.liaskoviti=
s@profitbricks.com">vasilis.liaskovitis@profitbricks.com</a>&gt;<br>
&gt;<br>
&gt; &gt; Hi,<br>
&gt; &gt;<br>
&gt; &gt; On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:<br>
&gt; &gt; &gt; At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:<br>
&gt; &gt; &gt; &gt; Hi Wen,<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; 2012/09/01 5:49, Andrew Morton wrote:<br>
&gt; &gt; &gt; &gt;&gt; On Tue, 28 Aug 2012 18:00:07 +0800<br>
&gt; &gt; &gt; &gt;&gt; <a href=3D"mailto:wency@cn.fujitsu.com">wency@cn.fu=
jitsu.com</a> wrote:<br>
&gt; &gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt; &gt;&gt;&gt; This patch series aims to support physical memo=
ry hot-remove.<br>
&gt; &gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt; &gt;&gt; I doubt if many people have hardware which permits =
physical memory<br>
&gt; &gt; &gt; &gt;&gt; removal? =A0How would you suggest that people with =
regular hardware can<br>
&gt; &gt; &gt; &gt;&gt; test these chagnes?<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; How do you test the patch? As Andrew says, for hot-remo=
ving memory,<br>
&gt; &gt; &gt; &gt; we need a particular hardware. I think so too. So many =
people may want<br>
&gt; &gt; &gt; &gt; to know how to test the patch.<br>
&gt; &gt; &gt; &gt; If we apply following patch to kvm guest, can we hot-re=
move memory on<br>
&gt; &gt; &gt; &gt; kvm guest?<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; <a href=3D"http://lists.gnu.org/archive/html/qemu-devel=
/2012-07/msg01389.html" target=3D"_blank">http://lists.gnu.org/archive/html=
/qemu-devel/2012-07/msg01389.html</a><br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Yes, if we apply this patchset, we can test hot-remove memor=
y on kvm<br>
&gt; &gt; guest.<br>
&gt; &gt; &gt; But that patchset doesn&#39;t implement _PS3, so there is so=
me restriction.<br>
&gt; &gt;<br>
&gt; &gt; the following repos contain the patchset above, plus 2 more patch=
es that<br>
&gt; &gt; add<br>
&gt; &gt; PS3 support to the dimm devices in qemu/seabios:<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"https://github.com/vliaskov/seabios/commits/memhp-v2" =
target=3D"_blank">https://github.com/vliaskov/seabios/commits/memhp-v2</a><=
br>
&gt; &gt; <a href=3D"https://github.com/vliaskov/qemu-kvm/commits/memhp-v2"=
 target=3D"_blank">https://github.com/vliaskov/qemu-kvm/commits/memhp-v2</a=
><br>
&gt; &gt;<br>
&gt; &gt; I have not posted the PS3 patches yet in the qemu list, but will =
post them<br>
&gt; &gt; soon for v3 of the memory hotplug series. If you have issues test=
ing, let<br>
&gt; &gt; me<br>
&gt; &gt; know.<br>
&gt; &gt;<br>
&gt; &gt; thanks,<br>
&gt; &gt;<br>
&gt; &gt; - Vasilis<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39=
; in<br>
&gt; &gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvac=
k.org</a>. =A0For more info on Linux MM,<br>
&gt; &gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http:=
//www.linux-mm.org/</a> .<br>
&gt; &gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont=
@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org"=
>email@kvack.org</a> &lt;/a&gt;<br>
&gt; &gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; --<br>
&gt; I love linux!!!<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Kind regards,<br>
Minchan Kim<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r>I love linux!!!<br>
</div>

--e89a8fb201e2126a2004c9663479--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
