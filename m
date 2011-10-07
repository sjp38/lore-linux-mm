Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2F69F6B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 11:23:48 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4d0a5da4-00de-40dd-8d75-8ed6e3d0831c@default>
Date: Fri, 7 Oct 2011 08:23:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: RFC -- new zone type
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default20111005165643.GE7007@labbmf-linux.qualcomm.com>
 <cc1256f9-4808-4d74-a321-6a3ec129cc05@default
 20111006230348.GF7007@labbmf-linux.qualcomm.com>
In-Reply-To: <20111006230348.GF7007@labbmf-linux.qualcomm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, Xen-devel@lists.xensource.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

> From: Larry Bassel [mailto:lbassel@codeaurora.org]
> Sent: Thursday, October 06, 2011 5:04 PM
> To: Dan Magenheimer
> Cc: Larry Bassel; linux-mm@kvack.org; Xen-devel@lists.xensource.com
> Subject: Re: [Xen-devel] Re: RFC -- new zone type
>=20
> Thanks for your answers to my questions. I have one more:
>=20
> Will there be any problem if the memory I want to be
> transcendent is highmem (i.e. doesn't have any permanent
> virtual<->physical mapping)?

Hi Larry --

I have to admit I am not an expert with highmem things.
Seth Jennings (cc'ed) fixed highmem for zcache with
a patch, so I assume that there shouldn't be a problem
for your code.

Dan

P.S. Seth, google for the subject if needed... there is
not a single email thread I can easily point you to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
