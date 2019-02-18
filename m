Date: Fri, 9 Jan 2004 15:21:58 +0100 (CET)
	<B.Zolnierkiewicz@elka.pw.edu.pl>
From: Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>
Subject: Re: 2.6.1-mm1
In-Reply-To: <Pine.LNX.4.58L.0401091550150.6458@alpha.zarz.agh.edu.pl>
Message-ID: <Pine.GSO.4.58.0401091515190.5021@mion.elka.pw.edu.pl>
References: <20040109014003.3d925e54.akpm@osdl.org>
 <Pine.LNX.4.58L.0401091550150.6458@alpha.zarz.agh.edu.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wojciech 'Sas' Cieciwa <cieciwa@alpha.zarz.agh.edu.pl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2004, Wojciech 'Sas' Cieciwa wrote:

> On Fri, 9 Jan 2004, Andrew Morton wrote:
>
> [...]
> >
> > - The PCI IDE drivers should work as modules now.

They always have worked as modules, it fixes case when PCI driver tried
to overtake interfaces already controlled by generic IDE code.

> shouldn't ..
> returned warnings like I've posted

You are talking about IDE as module not PCI IDE modules.

--bart
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
