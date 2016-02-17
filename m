Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id CEFC26B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 23:03:54 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id b35so3620871qge.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:03:54 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id v43si11070095qge.70.2016.02.16.20.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 20:03:54 -0800 (PST)
Received: by mail-qg0-x229.google.com with SMTP id b35so3620762qge.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:03:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160216182212.GA21071@obsidianresearch.com>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com> <56C08EC8.10207@mellanox.com> <20160216182212.GA21071@obsidianresearch.com>
From: davide rossetti <davide.rossetti@gmail.com>
Date: Tue, 16 Feb 2016 20:03:34 -0800
Message-ID: <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
Subject: Re: [RFC 0/7] Peer-direct memory
Content-Type: multipart/alternative; boundary=001a11395a229f29ff052bef5677
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

--001a11395a229f29ff052bef5677
Content-Type: text/plain; charset=UTF-8

On Tue, Feb 16, 2016 at 10:22 AM, Jason Gunthorpe <
jgunthorpe@obsidianresearch.com> wrote:

> On Sun, Feb 14, 2016 at 04:27:20PM +0200, Haggai Eran wrote:
> > [apologies: sending again because linux-mm address was wrong]
> >
> > On 11/02/2016 21:18, Jason Gunthorpe wrote:
> > > Resubmit those parts under the mm subsystem, or another more
> > > appropriate place.
> >
> > We want the feedback from linux-mm, and they are now Cced.
>
> Resubmit to mm means put this stuff someplace outside
> drivers/infiniband in the tree and don't try and inappropriately send
> memory management stuff through Doug's tree.
>
>
Jason,
I beg to differ.

1) I see mm as appropriate for real memory, i.e. something that user-space
apps can pass around.
This is not totally true for BAR memory, for instance as long as CPU
initiated atomic ops are not supported on BAR space of PCIe devices.
OTOT, CPU reading from BAR is awful (BW being abysmal,~10MB/s), while high
BW writing requires use of vector instructions (at least on x86_64).

2) Instead, I see appropriate that two sophisticated devices, like an IB
NIC and a storage/accelerator device, can freely target each other for I/O,
i.e. exchanging peer-to-peer PCIe transactions. And as long as the existing
sophisticated initiators are confined to the RDMA subsystem, that is where
this support belongs to.

On a different note, this reminds me that the current patch set may be
missing a way to disable the use of platform PCIe atomics when the target
is the BAR of a peer device.

-- 
sincerely,
d.

email: davide DOT rossetti AT gmail DOT com
work: drossetti AT nvidia DOT com
facebook: http://www.facebook.com/dado.rossetti
twitter: @dado_rossetti
skype: d.rossetti

--001a11395a229f29ff052bef5677
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Tue, Feb 16, 2016 at 10:22 AM, Jason Gunthorpe <span dir=3D"ltr">&lt;<a =
href=3D"mailto:jgunthorpe@obsidianresearch.com" target=3D"_blank">jgunthorp=
e@obsidianresearch.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_=
quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,=
204);padding-left:1ex"><span class=3D"">On Sun, Feb 14, 2016 at 04:27:20PM =
+0200, Haggai Eran wrote:<br>
&gt; [apologies: sending again because linux-mm address was wrong]<br>
&gt;<br>
&gt; On 11/02/2016 21:18, Jason Gunthorpe wrote:<br>
&gt; &gt; Resubmit those parts under the mm subsystem, or another more<br>
&gt; &gt; appropriate place.<br>
&gt;<br>
&gt; We want the feedback from linux-mm, and they are now Cced.<br>
<br>
</span>Resubmit to mm means put this stuff someplace outside<br>
drivers/infiniband in the tree and don&#39;t try and inappropriately send<b=
r>
memory management stuff through Doug&#39;s tree.<br>
<span class=3D""></span><br clear=3D"all"></blockquote></div><br></div><div=
 class=3D"gmail_extra">Jason,<br>I beg to differ. <br><br>1) I see mm as ap=
propriate for real memory, i.e. something that user-space apps can pass aro=
und.<br></div><div class=3D"gmail_extra">This is not totally true for BAR m=
emory, for instance as long as CPU initiated atomic ops are not supported o=
n BAR space of PCIe devices.<br></div><div class=3D"gmail_extra">OTOT, CPU =
reading from BAR is awful (BW being abysmal,~10MB/s), while high BW writing=
 requires use of vector instructions (at least on x86_64).<br></div><div cl=
ass=3D"gmail_extra"><br></div><div class=3D"gmail_extra">2) Instead, I see =
appropriate that two sophisticated devices, like an IB NIC and a storage/ac=
celerator device, can freely target each other for I/O, i.e. exchanging pee=
r-to-peer PCIe transactions. And as long as the existing sophisticated init=
iators are confined to the RDMA subsystem, that is where this support belon=
gs to.<br></div><div class=3D"gmail_extra"><br></div><div class=3D"gmail_ex=
tra">On a different note, this reminds me that the current patch set may be=
 missing a way to disable the use of platform PCIe atomics when the target =
is the BAR of a peer device.<br></div><div class=3D"gmail_extra"><br>-- <br=
><div class=3D"gmail_signature"><div dir=3D"ltr"><div>sincerely,</div><div>=
d.</div><div><br></div>email: davide DOT rossetti AT gmail DOT com<br>work:=
 drossetti AT nvidia DOT com<br>facebook: <a href=3D"http://www.facebook.co=
m/dado.rossetti" target=3D"_blank">http://www.facebook.com/dado.rossetti</a=
><br>twitter: @dado_rossetti<br>skype: d.rossetti</div></div>
</div></div>

--001a11395a229f29ff052bef5677--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
