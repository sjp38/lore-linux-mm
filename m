Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE2546B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:51:46 -0500 (EST)
Date: Tue, 10 Nov 2009 12:51:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm: slab allocate memory section nodemask for large
 systems
Message-Id: <20091110125131.30376c03.akpm@linux-foundation.org>
In-Reply-To: <20091102204726.GG5525@ldl.fc.hp.com>
References: <20091022040814.15705.95572.stgit@bob.kio>
	<20091022041510.15705.5410.stgit@bob.kio>
	<alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com>
	<20091027195907.GJ14102@ldl.fc.hp.com>
	<alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com>
	<20091028083137.GA24140@osiris.boeblingen.de.ibm.com>
	<alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com>
	<20091028183905.GF22743@ldl.fc.hp.com>
	<alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com>
	<20091102204726.GG5525@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: David Rientjes <rientjes@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 13:47:26 -0700
Alex Chiang <achiang@hp.com> wrote:

> I can respin this series once more, including David's Acked-by:
> and adding his patch if that makes life easier for you.

Yes, please redo and resend.

The prerequisite Documentation/ patches are a bit of a mess - some have
been cherrypicked into Greg's tree I believe and some haven't.  So
please also send out whatever is needed to bring linux-next up to date.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
