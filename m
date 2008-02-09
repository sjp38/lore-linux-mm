From: R S <srssum1ne@hotmail.com>
Subject: [ofa-general] trying to get of all lists
Date: Fri, 8 Feb 2008 16:21:37 -0800
Message-ID: <BAY104-W10A5647720759A7DFC8EBFEC280@phx.gbl>
References: <20080208220616.089936205@sgi.com>
	<20080208142315.7fe4b95e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
	<20080208233636.GG26564@sgi.com>
	<Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
	<20080208234302.GH26564@sgi.com>
	<20080208155641.2258ad2c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
	<adaprv70yyt.fsf@cisco.com>
	<Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1910716770=="
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: andrea@qumranet.com, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, general@lists.openfabrics.org, akpm@linux-foundation.org, kvm-devel@lists.sourceforge.net
List-Id: linux-mm.kvack.org

--===============1910716770==
Content-Type: multipart/alternative;
	boundary="_c649f4e0-ed06-4289-a4d7-018c07f30fe1_"

--_c649f4e0-ed06-4289-a4d7-018c07f30fe1_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

unsubscribe

> Date: Fri, 8 Feb 2008 16:16:34 -0800> From: clameter@sgi.com> To: rdreier=
@cisco.com> CC: akpm@linux-foundation.org; andrea@qumranet.com; a.p.zijlstr=
a@chello.nl; linux-mm@kvack.org; izike@qumranet.com; steiner@sgi.com; linux=
-kernel@vger.kernel.org; avi@qumranet.com; kvm-devel@lists.sourceforge.net;=
 daniel.blueman@quadrics.com; holt@sgi.com; general@lists.openfabrics.org> =
Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6> > On Fri, 8 Fe=
b 2008, Roland Dreier wrote:> > > In general, this MMU notifier stuff will =
only be useful to a subset of> > InfiniBand/RDMA hardware. Some adapters ar=
e smart enough to handle> > changing the IO virtual -> bus/physical mapping=
 on the fly, but some> > aren't. For the dumb adapters, I think the current=
 ib_umem_get() is> > pretty close to as good as we can get: we have to keep=
 the physical> > pages pinned for as long as the adapter is allowed to DMA =
into the> > memory region.> > I thought the adaptor can always remove the m=
apping by renegotiating > with the remote side? Even if its dumb then a cal=
lback could notify the > driver that it may be required to tear down the ma=
pping. We then hold the > pages until we get okay by the driver that the ma=
pping has been removed.> > We could also let the unmapping fail if the driv=
er indicates that the > mapping must stay.> --> To unsubscribe from this li=
st: send the line "unsubscribe linux-kernel" in> the body of a message to m=
ajordomo@vger.kernel.org> More majordomo info at http://vger.kernel.org/maj=
ordomo-info.html> Please read the FAQ at http://www.tux.org/lkml/
_________________________________________________________________
Shed those extra pounds with MSN and The Biggest Loser!
http://biggestloser.msn.com/=

--_c649f4e0-ed06-4289-a4d7-018c07f30fe1_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style>
.hmmessage P
{
margin:0px;
padding:0px
}
body.hmmessage
{
FONT-SIZE: 10pt;
FONT-FAMILY:Tahoma
}
</style>
</head>
<body class=3D'hmmessage'><BR><BR>unsubscribe<BR><BR>
<HR id=3DstopSpelling>
&gt; Date: Fri, 8 Feb 2008 16:16:34 -0800<BR>&gt; From: clameter@sgi.com<BR=
>&gt; To: rdreier@cisco.com<BR>&gt; CC: akpm@linux-foundation.org; andrea@q=
umranet.com; a.p.zijlstra@chello.nl; linux-mm@kvack.org; izike@qumranet.com=
; steiner@sgi.com; linux-kernel@vger.kernel.org; avi@qumranet.com; kvm-deve=
l@lists.sourceforge.net; daniel.blueman@quadrics.com; holt@sgi.com; general=
@lists.openfabrics.org<BR>&gt; Subject: Re: [ofa-general] Re: [patch 0/6] M=
MU Notifiers V6<BR>&gt; <BR>&gt; On Fri, 8 Feb 2008, Roland Dreier wrote:<B=
R>&gt; <BR>&gt; &gt; In general, this MMU notifier stuff will only be usefu=
l to a subset of<BR>&gt; &gt; InfiniBand/RDMA hardware. Some adapters are s=
mart enough to handle<BR>&gt; &gt; changing the IO virtual -&gt; bus/physic=
al mapping on the fly, but some<BR>&gt; &gt; aren't. For the dumb adapters,=
 I think the current ib_umem_get() is<BR>&gt; &gt; pretty close to as good =
as we can get: we have to keep the physical<BR>&gt; &gt; pages pinned for a=
s long as the adapter is allowed to DMA into the<BR>&gt; &gt; memory region=
.<BR>&gt; <BR>&gt; I thought the adaptor can always remove the mapping by r=
enegotiating <BR>&gt; with the remote side? Even if its dumb then a callbac=
k could notify the <BR>&gt; driver that it may be required to tear down the=
 mapping. We then hold the <BR>&gt; pages until we get okay by the driver t=
hat the mapping has been removed.<BR>&gt; <BR>&gt; We could also let the un=
mapping fail if the driver indicates that the <BR>&gt; mapping must stay.<B=
R>&gt; --<BR>&gt; To unsubscribe from this list: send the line "unsubscribe=
 linux-kernel" in<BR>&gt; the body of a message to majordomo@vger.kernel.or=
g<BR>&gt; More majordomo info at http://vger.kernel.org/majordomo-info.html=
<BR>&gt; Please read the FAQ at http://www.tux.org/lkml/<BR><br /><hr />She=
d those extra pounds with MSN and The Biggest Loser! <a href=3D'http://bigg=
estloser.msn.com/' target=3D'_new'>Learn more.</a></body>
</html>=

--_c649f4e0-ed06-4289-a4d7-018c07f30fe1_--

--===============1910716770==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1910716770==--
