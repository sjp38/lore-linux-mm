Date: Mon, 9 Jun 2003 20:19:45 +0200 (CEST)
From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: 2.5.70-mm6
In-Reply-To: <46580000.1055180345@flay>
Message-ID: <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv>
References: <20030607151440.6982d8c6.akpm@digeo.com>
 <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv> <46580000.1055180345@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If you don't nice the hell out of X, does it work OK?
No.

The way I reproduce the sound skips:
run xmms, run evolution, compose a mail with gpg.
on mm6 the gpg part stops the sound for a few seconds. (with X -10 and 0)
on mm5 xmms plays without stops. (with X -10)

Regards,
Maciej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
