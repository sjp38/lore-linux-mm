Date: Wed, 8 Dec 2004 13:26:27 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-Id: <20041208132627.1c73177e.davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	<20041202101029.7fe8b303.cliffw@osdl.org>
	<Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
	<200412080933.13396.jbarnes@engr.sgi.com>
	<Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: jbarnes@engr.sgi.com, nickpiggin@yahoo.com.au, jgarzik@pobox.com, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2004 09:56:00 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> A patch like this is important for applications that allocate and preset
> large amounts of memory on startup. It will drastically reduce the startup
> times.

I see.  Yet I noticed that while the patch makes system time decrease,
for some reason the wall time is increasing with the patch applied.
Why is that, or am I misreading your tables?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
