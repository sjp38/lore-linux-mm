Date: Fri, 24 Jan 2003 20:40:04 +0100 (MET)
From: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Reply-To: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Subject: Re: your mail
In-Reply-To: <Pine.LNX.4.44.0301241110470.10187-100000@dlang.diginsite.com>
Message-ID: <Pine.GSO.3.96.1030124203425.6763A-100000@delta.ds2.pg.gda.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Lang <david.lang@digitalinsight.com>
Cc: "Anoop J." <cs99001@nitc.ac.in>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Jan 2003, David Lang wrote:

> the cache never sees the virtual addresses, it operated excclusivly on the
> physical addresses so the problem of aliasing never comes up.

 It depends on the implementation.

> virtual to physical addres mapping is all resolved before anything hits
> the cache.

 It depends on the processor.

-- 
+  Maciej W. Rozycki, Technical University of Gdansk, Poland   +
+--------------------------------------------------------------+
+        e-mail: macro@ds2.pg.gda.pl, PGP key available        +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
