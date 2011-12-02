Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 504386B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 04:14:19 -0500 (EST)
MIME-Version: 1.0
In-Reply-To: <1322664737.2755.17.camel@menhir>
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support (was:Re: [BUG]
 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
Message-ID: <OF6A1EB29A.D9A6FBAC-ON8025795A.00311C05-8025795A.0032A610@LocalDomain>
From: mike.gair@tatasteel.com
Date: Fri, 2 Dec 2011 09:14:34 +0000
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Philipp Schafft <lion@lion.leolix.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>

<html><body><p><tt><font size=3D"2">Thanks,</font></tt><br><br><tt><font si=
ze=3D"2">I suspect I'm not up to the job,</font></tt><br><br><tt><font size=
=3D"2">- definitely not got an in-depth knowledge of the core Linux network=
ing stack</font></tt><br><tt><font size=3D"2">or the DECnet specs,</font></=
tt><br><tt><font size=3D"2">Have limited, but growing experience of C, (mai=
nly work in coral66)</font></tt><br><br><tt><font size=3D"2">But I'll have =
a look at code/documentation</font></tt><br><tt><font size=3D"2">&amp; see =
if I understand any of it. </font></tt><br><br><tt><font size=3D"2">Mike</f=
ont></tt><br><br><br><br><tt><font size=3D"2">Steven Whitehouse &lt;swhiteh=
o@redhat.com&gt; wrote on 30/11/2011 14:52:17:<br><br>&gt; Hi,<br>&gt; <br>=
&gt; On Wed, 2011-11-30 at 13:52 +0000, mike.gair@tatasteel.com wrote:<br>&=
gt; &gt; We're using decnet on linux,<br>&gt; &gt; as a way of expanding a =
control system,<br>&gt; &gt; using DEC PDP11s (actually charon11 emulations=
).<br>&gt; &gt; <br>&gt; &gt; So woud be very interested in keeping decnet =
supported.<br>&gt; &gt; <br>&gt; &gt; In theory i'd be interested in mainta=
ining it,<br>&gt; &gt; but i'm not sure what amount of work is involved,<br=
>&gt; &gt; have no experience of kernel, or where to start.<br>&gt; &gt; <b=
r>&gt; &gt; Any ideas?<br>&gt; &gt; <br>&gt; &gt; <br>&gt; So the issue is =
basically that due to there being nobody currently<br>&gt; maintaining the =
DECnet stack, it puts a burden on the core network<br>&gt; maintainers when=
 they make cross-protocol changes, as they have to<br>&gt; figure out what =
impact the changes are likely to have on the DECnet<br>&gt; stack. So its a=
n extra barrier to making cross-protocol code changes.<br>&gt; <br>&gt; If =
there was an active maintainer who could be a source of knowledge<br>&gt; (=
and the odd patch to help out making those changes) then this issue<br>&gt;=
 would largely go away.<br>&gt; <br>&gt; The most important duty of the mai=
ntainer is just to watch whats going<br>&gt; on in the core networking deve=
lopment and to contribute the DECnet part<br>&gt; of that. So it would be m=
ost likely be more a reviewing of patches and<br>&gt; providing advice role=
, than one of writing patches (though it could be<br>&gt; that too) and ens=
uring that the code continues to function correctly by<br>&gt; testing it f=
rom time to time.<br>&gt; <br>&gt; The ideal maintainer would have an in-de=
pth knowledge of the core Linux<br>&gt; networking stack (socket layer, dst=
 and neigh code), the DECnet specs<br>&gt; and have a good knowledge of C. =
<br>&gt; <br>&gt; Bearing in mind the low patch volume (almost zero, except=
 for core<br>&gt; stuff), it would probably be one of the subsystems with t=
he least amount<br>&gt; of work to do in maintaining it. So in some ways, a=
 good intro for a new<br>&gt; maintainer.<br>&gt; <br>&gt; I do try and kee=
p an eye on what get submitted to the DECnet code and<br>&gt; I'll continue=
 to do that while it is still in the kernel. However, it is<br>&gt; now qui=
te a long time since I last did any substantial work in the<br>&gt; network=
ing area and things have moved on a fair bit in the mean time. I<br>&gt; do=
n't have a lot of time to review DECnet patches these days and no way<br>&g=
t; to actually test any contributions against a real DECnet implementation.=
<br>&gt; <br>&gt; So I'll provide what help I can to anybody who wants to t=
ake the role<br>&gt; on, within those limitations. I'm also happy to answer=
 questions about<br>&gt; why things were done in a particular way, for exam=
ple.<br>&gt; <br>&gt; It is good to know that people are still using the Li=
nux DECnet code<br>&gt; too. It has lived far beyond the time when I'd envi=
sioned it still being<br>&gt; useful :-)<br>&gt; <br>&gt; Steve.<br>&gt; <b=
r>&gt; &gt; <br>&gt; &gt; <br>&gt; &gt; <br>&gt; &gt; Philipp Schafft &lt;l=
ion@lion.leolix.org&gt; wrote on 29/11/2011 14:47:19:<br>&gt; &gt; <br>&gt;=
 &gt; &gt; reflum,<br>&gt; &gt; &gt; <br>&gt; &gt; &gt; On Tue, 2011-11-29 =
at 15:34 +0100, Steven Whitehouse wrote:<br>&gt; &gt; &gt; <br>&gt; &gt; &g=
t; &gt; Has anybody actually tested it<br>&gt; &gt; &gt; &gt; &gt; &gt;&gt;=
 lately against &quot;real&quot; DEC implementations?<br>&gt; &gt; &gt; &gt=
; &gt; &gt; I doubt it :-)<br>&gt; &gt; &gt; &gt; &gt; DECnet is in use aga=
inst real DEC implementations - I have<br>&gt; &gt; checked it <br>&gt; &gt=
; &gt; &gt; &gt; quite recently against a VAX running OpenVMS. How many peo=
ple<br>&gt; &gt; are <br>&gt; &gt; &gt; &gt; &gt; actually using it for rea=
l work is a different question though.<br>&gt; &gt; &gt; &gt; &gt; <br>&gt;=
 &gt; &gt; &gt; Ok, thats useful info.<br>&gt; &gt; &gt; <br>&gt; &gt; &gt;=
 I confirmed parts of it with tcpdump and the specs some weeks ago.<br>&gt;=
 &gt; The<br>&gt; &gt; &gt; parts I worked on passed :) I also considered t=
o send the tcpdump<br>&gt; &gt; &gt; upstream a patch for protocol decoding=
.<br>&gt; &gt; &gt; <br>&gt; &gt; &gt; <br>&gt; &gt; &gt; &gt; &gt; It's al=
so true that it's not really supported by anyone as I<br>&gt; &gt; orphaned=
 it <br>&gt; &gt; &gt; &gt; &gt; some time ago and nobody else seems to car=
e enough to take it<br>&gt; &gt; over. So <br>&gt; &gt; &gt; &gt; &gt; if i=
t's becoming a burden on people doing real kernel work then<br>&gt; &gt; I =
don't <br>&gt; &gt; &gt; &gt; &gt; think many tears will be wept for its re=
moval.<br>&gt; &gt; &gt; &gt; &gt; Chrissie<br>&gt; &gt; &gt; &gt; <br>&gt;=
 &gt; &gt; &gt; Really the only issue with keeping it around is the mainten=
ance<br>&gt; &gt; burden I<br>&gt; &gt; &gt; &gt; think. It doesn't look li=
ke anybody wants to take it on, but maybe<br>&gt; &gt; we<br>&gt; &gt; &gt;=
 &gt; should give it another few days for someone to speak up, just in<br>&=
gt; &gt; case<br>&gt; &gt; &gt; &gt; they are on holiday or something at th=
e moment.<br>&gt; &gt; &gt; &gt; <br>&gt; &gt; &gt; &gt; Also, I've updated=
 the subject of the thread, to make it more<br>&gt; &gt; obvious<br>&gt; &g=
t; &gt; &gt; what is being discussed, as well as bcc'ing it again to the DE=
Cnet<br>&gt; &gt; list,<br>&gt; &gt; &gt; <br>&gt; &gt; &gt; I'm very inter=
ested in the module. However my problem is that I had<br>&gt; &gt; &gt; not=
hing to do with kernel coding yet. However I'm currently<br>&gt; &gt; searc=
hing a<br>&gt; &gt; &gt; new maintainer for it (I got info about this threa=
d by today).<br>&gt; &gt; &gt; If somebody is interested in this and only n=
eeds some &quot;motivation&quot;<br>&gt; &gt; or<br>&gt; &gt; &gt; maybe so=
meone would like to get me into kernel coding, please just<br>&gt; &gt; &gt=
; reply :)<br>&gt; &gt; &gt; <br>&gt; &gt; &gt; -- <br>&gt; &gt; &gt; Phili=
pp.<br>&gt; &gt; &gt; (Rah of PH2)<br>&gt; &gt; &gt; [attachment &quot;sign=
ature.asc&quot; deleted by Mike Gair/UK/Corus] <br>&gt; &gt; &gt;<br>&gt; &=
gt; <br>&gt; --------------------------------------------------------------=
----------------<br>&gt; &gt; &gt; All the data continuously generated in y=
our IT infrastructure <br>&gt; &gt; &gt; contains a definitive record of cu=
stomers, application performance, <br>&gt; &gt; &gt; security threats, frau=
dulent activity, and more. Splunk takes this <br>&gt; &gt; &gt; data and ma=
kes sense of it. IT sense. And common sense.<br>&gt; &gt; &gt; <a href=3D"h=
ttp://p.sf.net/sfu/splunk-novd2d">http://p.sf.net/sfu/splunk-novd2d</a><br>=
&gt; &gt; &gt; =5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F<br>&gt; &gt; &gt; Project Home Page: <a href=3D"http://linux-decnet.=
wiki.sourceforge.net/">http://linux-decnet.wiki.sourceforge.net/</a><br>&gt=
; &gt; &gt; <br>&gt; &gt; &gt; Linux-decnet-user mailing list<br>&gt; &gt; =
&gt; Linux-decnet-user@lists.sourceforge.net<br>&gt; &gt; &gt; <a href=3D"h=
ttps://lists.sourceforge.net/lists/listinfo/linux-decnet-user">https://list=
s.sourceforge.net/lists/listinfo/linux-decnet-user</a><br>&gt; &gt; &gt; <b=
r>&gt; &gt; <br>&gt; &gt; <br>&gt; &gt; ***********************************=
***********************************<br>&gt; &gt; This transmission is confi=
dential and must not be used or disclosed by<br>&gt; &gt; anyone other than=
 the intended recipient. Neither Tata Steel Europe<br>&gt; &gt; Limited nor=
 any of its subsidiaries can accept any responsibility for<br>&gt; &gt; any=
 use or misuse of the transmission by anyone. <br>&gt; &gt; <br>&gt; &gt; F=
or address and company registration details of certain entities<br>&gt; &gt=
; within the Tata Steel Europe group of companies, please visit<br>&gt; &gt=
; <a href=3D"http://www.tatasteeleurope.com/entities">http://www.tatasteele=
urope.com/entities</a><br>&gt; &gt; ***************************************=
*******************************<br>&gt; &gt; <br>&gt; <br>&gt; <br></font><=
/tt><font face=3D"sans-serif"><P><font size=3D"2" face=3D"Arial">
**********************************************************************<BR>
This transmission is confidential and must not be used or disclosed by anyo=
ne other than the intended recipient. Neither Tata Steel Europe Limited nor=
 any of its subsidiaries can accept any responsibility for any use or misus=
e of the transmission by anyone.
<BR><BR>
For address and company registration details of certain entities within the=
 Tata Steel Europe group of companies, please visit
<A HREF=3D"http://www.tatasteeleurope.com/entities">http://www.tatasteeleur=
ope.com/entities</A><BR>
**********************************************************************</P><=
/font>
</body></html>

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
