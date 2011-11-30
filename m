Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C943F6B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:51:48 -0500 (EST)
MIME-Version: 1.0
In-Reply-To: <20111129144720.7374B7AD9E@priderock.keep-cool.org>
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support (was:Re: [BUG]
 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
Message-ID: <OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
From: mike.gair@tatasteel.com
Date: Wed, 30 Nov 2011 13:52:11 +0000
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Schafft <lion@lion.leolix.org>
Cc: Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>, Steven Whitehouse <swhiteho@redhat.com>

<html><body><p><font size=3D"2" face=3D"sans-serif">We're  using decnet on =
linux,</font><br><font size=3D"2" face=3D"sans-serif">as a way of expanding=
  a  control system,</font><br><font size=3D"2" face=3D"sans-serif">using D=
EC PDP11s (actually charon11 emulations).</font><br><br><font size=3D"2" fa=
ce=3D"sans-serif">So woud be very interested in keeping decnet supported.</=
font><br><br><font size=3D"2" face=3D"sans-serif">In theory i'd be interest=
ed in maintaining it,</font><br><font size=3D"2" face=3D"sans-serif">but i'=
m not sure what amount of work is involved,</font><br><font size=3D"2" face=
=3D"sans-serif">have no experience of kernel, or where to start.</font><br>=
<br><font size=3D"2" face=3D"sans-serif">Any ideas?</font><br><br><br><br><=
br><br><tt><font size=3D"2">Philipp Schafft &lt;lion@lion.leolix.org&gt; wr=
ote on 29/11/2011 14:47:19:<br><br>&gt; reflum,<br>&gt; <br>&gt; On Tue, 20=
11-11-29 at 15:34 +0100, Steven Whitehouse wrote:<br>&gt; <br>&gt; &gt; Has=
 anybody actually tested it<br>&gt; &gt; &gt; &gt;&gt; lately against &quot=
;real&quot; DEC implementations?<br>&gt; &gt; &gt; &gt; I doubt it :-)<br>&=
gt; &gt; &gt; DECnet is in use against real DEC implementations - I have ch=
ecked it <br>&gt; &gt; &gt; quite recently against a VAX running OpenVMS. H=
ow many people are <br>&gt; &gt; &gt; actually using it for real work is a =
different question though.<br>&gt; &gt; &gt; <br>&gt; &gt; Ok, thats useful=
 info.<br>&gt; <br>&gt; I confirmed parts of it with tcpdump and the specs =
some weeks ago. The<br>&gt; parts I worked on passed :) I also considered t=
o send the tcpdump<br>&gt; upstream a patch for protocol decoding.<br>&gt; =
<br>&gt; <br>&gt; &gt; &gt; It's also true that it's not really supported b=
y anyone as I orphaned it <br>&gt; &gt; &gt; some time ago and nobody else =
seems to care enough to take it over. So <br>&gt; &gt; &gt; if it's becomin=
g a burden on people doing real kernel work then I don't <br>&gt; &gt; &gt;=
 think many tears will be wept for its removal.<br>&gt; &gt; &gt; Chrissie<=
br>&gt; &gt; <br>&gt; &gt; Really the only issue with keeping it around is =
the maintenance burden I<br>&gt; &gt; think. It doesn't look like anybody w=
ants to take it on, but maybe we<br>&gt; &gt; should give it another few da=
ys for someone to speak up, just in case<br>&gt; &gt; they are on holiday o=
r something at the moment.<br>&gt; &gt; <br>&gt; &gt; Also, I've updated th=
e subject of the thread, to make it more obvious<br>&gt; &gt; what is being=
 discussed, as well as bcc'ing it again to the DECnet list,<br>&gt; <br>&gt=
; I'm very interested in the module. However my problem is that I had<br>&g=
t; nothing to do with kernel coding yet. However I'm currently searching a<=
br>&gt; new maintainer for it (I got info about this thread by today).<br>&=
gt; If somebody is interested in this and only needs some &quot;motivation&=
quot; or<br>&gt; maybe someone would like to get me into kernel coding, ple=
ase just<br>&gt; reply :)<br>&gt; <br>&gt; -- <br>&gt; Philipp.<br>&gt;  (R=
ah of PH2)<br>&gt; [attachment &quot;signature.asc&quot; deleted by Mike Ga=
ir/UK/Corus] <br>&gt; -----------------------------------------------------=
-------------------------<br>&gt; All the data continuously generated in yo=
ur IT infrastructure <br>&gt; contains a definitive record of customers, ap=
plication performance, <br>&gt; security threats, fraudulent activity, and =
more. Splunk takes this <br>&gt; data and makes sense of it. IT sense. And =
common sense.<br>&gt; <a href=3D"http://p.sf.net/sfu/splunk-novd2d">http://=
p.sf.net/sfu/splunk-novd2d</a><br>&gt; =5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F<br>&gt; Project Home Page: <a href=3D"http:/=
/linux-decnet.wiki.sourceforge.net/">http://linux-decnet.wiki.sourceforge.n=
et/</a><br>&gt; <br>&gt; Linux-decnet-user mailing list<br>&gt; Linux-decne=
t-user@lists.sourceforge.net<br>&gt; <a href=3D"https://lists.sourceforge.n=
et/lists/listinfo/linux-decnet-user">https://lists.sourceforge.net/lists/li=
stinfo/linux-decnet-user</a><br>&gt; <br></font></tt><font face=3D"sans-ser=
if"><P><font size=3D"2" face=3D"Arial">
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
