Date: Fri, 21 Sep 2001 23:01:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
In-Reply-To: <5D2F375D116BD111844C00609763076E050D1658@exch-staff1.ul.ie>
Message-ID: <Pine.LNX.4.33L.0109212300101.19147-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Cc: Benjamin LaHaise <bcrl@redhat.com>, "'ebiederm@xmission.com'" <ebiederm@xmission.com>, "'tvignaud@mandrakesoft.com'" <tvignaud@mandrakesoft.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'brian@worldcontrol.com'" <brian@worldcontrol.com>, "'arjan@fenrus.demon.nl'" <arjan@fenrus.demon.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2001, Gabriel.Leen wrote:

> Unfortunately the package which I am using is a pre-compiled
> distribution, so that limits what I can do with it :(

1) install the hoard malloc library
2) LD_PRELOAD=/path/to/libhoard.so

3) have fun ;)

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
