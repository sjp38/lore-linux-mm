Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF1EB9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 11:59:31 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8MFxSQ5017571
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:59:28 -0700
Received: from gxk26 (gxk26.prod.google.com [10.202.11.26])
	by hpaq13.eem.corp.google.com with ESMTP id p8MFxQOW012148
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:59:27 -0700
Received: by gxk26 with SMTP id 26so1508066gxk.41
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:59:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316693805.10571.25.camel@dabdike>
References: <1316693805.10571.25.camel@dabdike>
From: Tim Hockin <thockin@google.com>
Date: Thu, 22 Sep 2011 08:59:05 -0700
Message-ID: <CAO_RewY98hakC658tqX0vKqFxfFpnvs-_xbTWtFZcvgWdWbrVA@mail.gmail.com>
Subject: Re: Proposed memcg meeting at October Kernel Summit/European LinuxCon
 in Prague
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <jbottomley@parallels.com>
Cc: Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

It is unlikely that I or anyone on my direct team (the userspace
management side) will be able to attend, but You obviously have the
key players from the kernel side of Google on this list.  I'll put it
to my team to see if anyone is able to make it.

On Thu, Sep 22, 2011 at 5:16 AM, James Bottomley
<jbottomley@parallels.com> wrote:
> Hi All,
>
> One of the major work items that came out of the Plumbers conference
> containers and Cgroups meeting was the need to work on memcg:
>
> http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/tracks/105
>
> (see etherpad and presentations)
>
> Since almost everyone will be either at KS or LinuxCon, I thought doing
> a small meeting on the Wednesday of Linux Con (so those at KS who might
> not be staying for the whole of LinuxCon could attend) might be a good
> idea. =A0The object would be to get all the major players to agree on
> who's doing what. =A0You can see Parallels' direction from the patches
> Glauber has been posting. =A0Google should shortly be starting work on
> other aspects of the memgc as well.
>
> As a precursor to the meeting (and actually a requirement to make it
> effective) we need to start posting our preliminary patches and design
> ideas to the mm list (hint, Google people, this means you).
>
> I think I've got all of the interested parties in the To: field, but I'm
> sending this to the mm list just in case I missed anyone. =A0If everyone'=
s
> OK with the idea (and enough people are going to be there) I'll get the
> Linux Foundation to find us a room.
>
> James
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
