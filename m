Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEC6900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 12:36:54 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 5 Jul 2011 12:36:43 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
In-Reply-To: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Dan Magenheimer
> Sent: July 05, 2011 11:54 AM
> To: netdev@vger.kernel.org
> Cc: Konrad Wilk; linux-mm
> Subject: [RFC] non-preemptible kernel socket for RAMster
>=20
> In working on a kernel project called RAMster* (where RAM on a
> remote system may be used for clean page cache pages and for swap
> pages), I found I have need for a kernel socket to be used when


How is RAMster+swap different than NBD's (pending etc?)support for SWAP
over NBD?


Chetan Loke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
