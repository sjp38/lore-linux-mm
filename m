Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 9E7A838C20
	for <linux-mm@kvack.org>; Mon, 24 Sep 2001 22:38:18 -0300 (EST)
Date: Mon, 24 Sep 2001 19:49:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
In-Reply-To: <5D2F375D116BD111844C00609763076E050D1681@exch-staff1.ul.ie>
Message-ID: <Pine.LNX.4.33L.0109241949110.1864-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Resent-To: <Gabriel.Leen@ul.ie>, <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33L.0109242237510.15233@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Cc: Benjamin LaHaise <bcrl@redhat.com>, "'ebiederm@xmission.com'" <ebiederm@xmission.com>, "'tvignaud@mandrakesoft.com'" <tvignaud@mandrakesoft.com>, "'brian@worldcontrol.com'" <brian@worldcontrol.com>, "'arjan@fenrus.demon.nl'" <arjan@fenrus.demon.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Sep 2001, Gabriel.Leen wrote:

> I hope (fingers crossed) that there is some way around this
> I think that Redhat  now supports up to 64GB of ram,
> as the Xeon has 36 address lines, see attached.
>
> I'm only grasping at straws here, but I hope that it is somehow
> possible on this machine?

The Xeon allows up to 36 bits of physical memory,
but still only 32 bits of virtual address space
per process...

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
