Received: from pincoya.inf.utfsm.cl (root@pincoya.inf.utfsm.cl [200.1.19.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA05354
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 19:40:45 -0400
Message-Id: <199904052337.TAA32120@pincoya.inf.utfsm.cl>
Subject: Re: [patch] arca-vm-2.2.5 
In-reply-to: Your message of "Tue, 06 Apr 1999 01:25:15 +0200."
             <Pine.LNX.4.05.9904060124010.447-100000@laser.random>
Date: Mon, 05 Apr 1999 19:37:13 -0400
From: Horst von Brand <vonbrand@inf.utfsm.cl>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Horst von Brand <vonbrand@inf.utfsm.cl>, Mark Hemment <markhe@sco.COM>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@e-mind.com> said:
> On Mon, 5 Apr 1999, Horst von Brand wrote:
> >If you link new pages in at the start (would make sense, IMHO, since they
> >will probably be used soon) you can just use the pointer as cookie.

> You can have two points of the kernel that are sleeping waiting to alloc
> memory for a cache page at the same time.

So what? One wakes up, finds the same pointer it stashed away ==> Installs
new page (changing pointer) via short way. Second wakes up, finds pointer
changed ==> goes long way to do its job.

Or am I overlooking something stupid?
-- 
Dr. Horst H. von Brand                       mailto:vonbrand@inf.utfsm.cl
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
