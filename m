Content-Type: text/plain;
  charset="iso-8859-1"
From: Marc-Christian Petersen <m.c.p@wolk-project.de>
Subject: Re: [PATCH] rmap 15e
Date: Wed, 12 Mar 2003 21:53:54 +0100
References: <Pine.LNX.4.44.0303121516270.3890-100000@dhcp64-226.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0303121516270.3890-100000@dhcp64-226.boston.redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200303122153.28046.m.c.p@wolk-project.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 12 March 2003 21:19, Rik van Riel wrote:

Hi Rik,

> After a change to a new house, in a new city, in a new country
> and with a new job I finally have time for -rmap development again.
> Curious what happened to me?  http://surriel.com/nh.shtml ;)
I hope you are feeling very well at your new house/city/job :)

> rmap 15e:
>   - make reclaiming unused inodes more efficient       (Arjan van de Ven)
>     | push to Marcelo and Andrew once it's well tested !
>   - fix DRM memory leak                                (Arjan van de Ven)
>   - fix potential infinite loop in kswapd                 (me)
>   - clean up elevator.h (no IO scheduler in -rmap...)     (me)
>   - page aging interval tuned on a per zone basis, better
>     wakeup mechanism for sudden memory pressure           (Arjan, me)
Great to see this!! Many thanks. I've merged this for WOLK v4.0s-rc4 upcoming 
within the next days.

ciao, Marc
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
